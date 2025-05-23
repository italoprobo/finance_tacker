import 'package:dio/dio.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _apiKey = 'AIzaSyBVmZiKdmpm6XtY0voYhXraZ9vNNrVCB-I'; 
  
  final Dio _dio = Dio();

  Future<String> sendMessage(String message, {String? userContext}) async {
    try {
      final prompt = _buildPrompt(message, userContext);
      
      final response = await _dio.post(
        '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": prompt
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topP": 1,
            "topK": 1,
            "maxOutputTokens": 1000,
          }
        },
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Desculpe, houve um erro ao processar sua mensagem.';
      }
    } catch (e) {
      print('Erro na API Gemini: $e');
      return 'Desculpe, não consegui processar sua mensagem no momento.';
    }
  }

  String _buildPrompt(String userMessage, String? userContext) {
    return '''
Você é um assistente financeiro IA especializado em ajudar com gestão de finanças pessoais.

${userContext != null && userContext.isNotEmpty ? 'DADOS FINANCEIROS DO USUÁRIO:\n$userContext\n' : ''}

INSTRUÇÕES IMPORTANTES:
- Responda sempre em português brasileiro
- Seja objetivo, didático e útil
- Use os dados financeiros do usuário para dar conselhos personalizados
- Analise padrões de gastos e sugira melhorias
- Se perguntado sobre dados específicos, use as informações fornecidas
- Forneça dicas práticas sobre finanças baseadas nos dados do usuário
- Se a pergunta não for sobre finanças, redirecione educadamente para temas financeiros
- Mantenha as respostas concisas mas informativas (máximo 300 palavras)
- Seja empático e motivador

FORMATO DA RESPOSTA:
- NÃO use asteriscos (*) ou outros símbolos de markdown para formatação
- Use apenas texto simples
- Para destacar informações importantes, use MAIÚSCULAS
- Para listas, use hífen (-) simples
- Para separar seções, use linha em branco

ENTENDA OS TIPOS DE TRANSAÇÃO:
- RECEITA = entrada de dinheiro (salários, vendas, pagamentos recebidos)
- DESPESA = saída de dinheiro (compras, contas, gastos)

PERGUNTA: $userMessage

RESPOSTA:''';
  }
}