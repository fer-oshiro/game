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
	# Código JavaScript em formato de String
	var js_code = """
		window.requestMicPermission = async function() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                stream.getTracks().forEach(track => track.stop());
              
                window.recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
                window.recognition.lang = 'pt-BR';
                window.recognition.interimResults = false;
                window.recognition.onresult = function(event) {
                    window.godot_speech_callback(event.results[0][0].transcript);
                };
              
                console.log("Microfone liberado!");
                return true;
            } catch (error) {
                console.error("Erro no microfone:", error.name);
                return false;
            }
        };
    """
	JavaScriptBridge.eval(js_code)
	
	# Cria uma função que o JavaScript pode chamar para devolver o texto
	var callback = JavaScriptBridge.create_callback(_on_speech_received)
	JavaScriptBridge.get_interface("window").godot_speech_callback = callback

func permission():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.requestMicPermission();")
		print("Ouvindo...")

func start_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.recognition.start();")
		print("Ouvindo...")

func stop_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.recognition.stop();")
		print("Parou de ouvir.")

# Esta função é chamada quando o navegador entende a voz
func _on_speech_received(args):
	text_received = args[0]
	print("O navegador ouviu: ", text_received)
	texto_reconhecido.emit(text_received)
