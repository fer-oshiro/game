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
		window.startSpeechRecognition = async function() {
			try {
				const SpeechRecognitionClass = window.SpeechRecognition || window.webkitSpeechRecognition;

				if (!SpeechRecognitionClass) {
					console.error("Web Speech API não suportada neste navegador.");
					return;
				}

				const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
				stream.getTracks().forEach(track => track.stop());

				window.recognition = new SpeechRecognitionClass();
				window.recognition.lang = 'pt-BR';
				window.recognition.interimResults = false;
				window.recognition.continuous = false;

				window.recognition.onresult = function(event) {
					const text = event.results[0][0].transcript;
					console.log("Texto reconhecido:", text);
					window.godot_speech_callback(text);
				};

				window.recognition.onerror = function(event) {
					console.error("Erro no recognition:", event.error);
				};

				window.recognition.onend = function() {
					console.log("Reconhecimento encerrado.");
				};

				console.log("Microfone liberado, iniciando reconhecimento...");
				window.recognition.start();

			} catch (error) {
				console.error("Erro no microfone:", error);
			}
		};

		window.stopSpeechRecognition = function() {
			if (window.recognition) {
				window.recognition.stop();
				console.log("Parado manualmente.");
			}
		};
	"""
	JavaScriptBridge.eval(js_code)
func permission():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.requestMicPermission();")
		print("Ouvindo...")

func start_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.startSpeechRecognition();")
		print("Ouvindo...")

func stop_listening():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.stopSpeechRecognition();")
		print("Parou de ouvir.")

# Esta função é chamada quando o navegador entende a voz
func _on_speech_received(args):
	text_received = args[0]
	print("O navegador ouviu: ", text_received)
	texto_reconhecido.emit(text_received)
