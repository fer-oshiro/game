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
        window.recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
        window.recognition.lang = 'pt-BR';
        window.recognition.interimResults = false;

        window.recognition.onresult = function(event) {
            var text = event.results[0][0].transcript;
            // Envia o texto de volta para o Godot
            window.godot_speech_callback(text);
        };
    """
	JavaScriptBridge.eval(js_code)
	
	# Cria uma função que o JavaScript pode chamar para devolver o texto
	var callback = JavaScriptBridge.create_callback(_on_speech_received)
	JavaScriptBridge.get_interface("window").godot_speech_callback = callback

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
