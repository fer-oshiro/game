extends Node

var score:int = 999

var recognition # O objeto de reconhecimento de voz no JS
var text_received
signal texto_reconhecido(texto)

func _ready():
	# Verifica se estamos rodando no navegador
	if OS.has_feature("web"):
		setup_speech_recognition()

func setup_speech_recognition():
	var callback = JavaScriptBridge.create_callback(_on_speech_received)
	JavaScriptBridge.get_interface("window").godot_speech_callback = callback
	var js_code = """
	    window.startRecording = async function() {
	        try {
	            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
	            const chunks = [];

	            window.mediaRecorder = new MediaRecorder(stream);

	            window.mediaRecorder.ondataavailable = function(event) {
	                console.log("Chunk recebido, tamanho:", event.data.size);
	                if (event.data.size > 0) {
	                    chunks.push(event.data);
	                }
	            };

	            window.mediaRecorder.onstop = async function() {
	                console.log("onstop chamado, chunks:", chunks.length);
	                
	                const blob = new Blob(chunks, { type: 'audio/webm' });
	                console.log("Blob size:", blob.size);
	                
	                const arrayBuffer = await blob.arrayBuffer();
	                const bytes = new Uint8Array(arrayBuffer);

	                let binary = '';
	                bytes.forEach(b => binary += String.fromCharCode(b));
	                const base64 = btoa(binary);

	                const response = await fetch('https://a3az34kyk44xowasglwg6epsmy0kfmeh.lambda-url.us-east-1.on.aws/', {
	                    method: 'POST',
	                    headers: { 'Content-Type': 'application/json' },
	                    body: JSON.stringify({ audio: base64 })
	                });

	                const data = await response.json();
	                console.log("Texto recebido:", data.text);
	                
	                if (window.godot_speech_callback) {
	                    window.godot_speech_callback(data.text);
	                } else {
	                    console.error("godot_speech_callback nao existe!");
	                }
	            };

	            window.mediaRecorder.start(100);
	            console.log("Gravando...");

	        } catch (error) {
	            console.error("Erro ao gravar:", error);
	        }
	    };

	    window.stopRecording = function() {
	        if (window.mediaRecorder && window.mediaRecorder.state !== 'inactive') {
	            window.mediaRecorder.requestData();
	            window.mediaRecorder.stop();
	            console.log("Gravação encerrada.");
	        }
	    };
	"""
	JavaScriptBridge.eval(js_code)	

func start_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.startRecording();")
		print("Gravando...")

func stop_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.stopRecording();")
		print("Parou de gravar.")

# Esta função é chamada quando o navegador entende a voz
func _on_speech_received(args):
	
	text_received = args[0]
	print("O navegador ouviu: ", text_received)
	texto_reconhecido.emit(text_received)
	
	
