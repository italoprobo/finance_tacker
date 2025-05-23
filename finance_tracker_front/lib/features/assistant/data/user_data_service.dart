import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';

class UserDataService {
  static String getUserFinancialContext({
    required AuthState authState,
    required CardState cardState,
    required TransactionState transactionState,
  }) {
    try {
      StringBuffer contextBuffer = StringBuffer();
      
      // Informações básicas do usuário
      if (authState is AuthSuccess) {
        contextBuffer.writeln('--- PERFIL DO USUÁRIO ---');
        contextBuffer.writeln('Nome: ${authState.name}');
        contextBuffer.writeln('Email: ${authState.email}');
      }

      // Informações de cartões
      if (cardState is CardSuccess) {
        contextBuffer.writeln('\n--- CARTÕES DO USUÁRIO ---');
        double totalLimite = 0;
        double totalUtilizado = 0;
        
        for (var card in cardState.cards) {
          contextBuffer.writeln('• ${card.name} (****${card.lastDigits}):');
          contextBuffer.writeln('  - Limite: R\$ ${card.limit.toStringAsFixed(2)}');
          contextBuffer.writeln('  - Saldo atual: R\$ ${card.currentBalance.toStringAsFixed(2)}');
          contextBuffer.writeln('  - Tipos: ${card.cardType.join(', ')}');
          if (card.closingDay != null) {
            contextBuffer.writeln('  - Fechamento: dia ${card.closingDay}');
          }
          if (card.dueDay != null) {
            contextBuffer.writeln('  - Vencimento: dia ${card.dueDay}');
          }
          
          totalLimite += card.limit;
          totalUtilizado += card.currentBalance;
        }
        
        contextBuffer.writeln('\n--- RESUMO DOS CARTÕES ---');
        contextBuffer.writeln('Total de cartões: ${cardState.cards.length}');
        contextBuffer.writeln('Limite total: R\$ ${totalLimite.toStringAsFixed(2)}');
        contextBuffer.writeln('Total utilizado: R\$ ${totalUtilizado.toStringAsFixed(2)}');
        contextBuffer.writeln('Limite disponível: R\$ ${(totalLimite - totalUtilizado).toStringAsFixed(2)}');
        double percentualUso = totalLimite > 0 ? (totalUtilizado / totalLimite) * 100 : 0;
        contextBuffer.writeln('Percentual de uso: ${percentualUso.toStringAsFixed(1)}%');
      }

      // Análise completa de TODAS as transações
      if (transactionState is TransactionsSuccess) {
        var allTransactions = transactionState.transactions;
        
        contextBuffer.writeln('\n--- ANÁLISE COMPLETA DAS TRANSAÇÕES ---');
        contextBuffer.writeln('Total de transações: ${allTransactions.length}');
        
        // Totais gerais
        double totalReceitas = 0;
        double totalDespesas = 0;
        Map<String, double> categoriasDespesas = {};
        Map<String, double> categoriasReceitas = {};
        Map<String, int> frequenciaDescricoes = {};
        Map<String, double> gastosPorCliente = {};
        Map<String, double> receitasPorCliente = {};
        Map<int, double> gastosPorMes = {};
        Map<int, double> receitasPorMes = {};
        
        for (var transaction in allTransactions) {
          String descricao = transaction.description.toLowerCase().trim();
          int mesAno = transaction.date.year * 100 + transaction.date.month;
          
          // Contagem de frequência
          frequenciaDescricoes[descricao] = (frequenciaDescricoes[descricao] ?? 0) + 1;
          
          if (transaction.type == 'entrada') {
            totalReceitas += transaction.amount;
            categoriasReceitas[descricao] = (categoriasReceitas[descricao] ?? 0) + transaction.amount;
            receitasPorMes[mesAno] = (receitasPorMes[mesAno] ?? 0) + transaction.amount;
            
            if (transaction.client != null) {
              String clienteNome = transaction.client!.name;
              receitasPorCliente[clienteNome] = (receitasPorCliente[clienteNome] ?? 0) + transaction.amount;
            }
          } else {
            double valor = transaction.amount.abs();
            totalDespesas += valor;
            categoriasDespesas[descricao] = (categoriasDespesas[descricao] ?? 0) + valor;
            gastosPorMes[mesAno] = (gastosPorMes[mesAno] ?? 0) + valor;
            
            if (transaction.client != null) {
              String clienteNome = transaction.client!.name;
              gastosPorCliente[clienteNome] = (gastosPorCliente[clienteNome] ?? 0) + valor;
            }
          }
        }
        
        contextBuffer.writeln('\n--- TOTAIS GERAIS ---');
        contextBuffer.writeln('Total de receitas: R\$ ${totalReceitas.toStringAsFixed(2)}');
        contextBuffer.writeln('Total de despesas: R\$ ${totalDespesas.toStringAsFixed(2)}');
        contextBuffer.writeln('Saldo líquido total: R\$ ${(totalReceitas - totalDespesas).toStringAsFixed(2)}');
        
        // Principais categorias de despesas
        if (categoriasDespesas.isNotEmpty) {
          contextBuffer.writeln('\n--- PRINCIPAIS CATEGORIAS DE DESPESAS ---');
          var sortedDespesas = categoriasDespesas.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          for (var entry in sortedDespesas.take(10)) {
            int frequencia = frequenciaDescricoes[entry.key] ?? 0;
            contextBuffer.writeln('• ${entry.key}: R\$ ${entry.value.toStringAsFixed(2)} (${frequencia}x)');
          }
        }
        
        // Principais categorias de receitas
        if (categoriasReceitas.isNotEmpty) {
          contextBuffer.writeln('\n--- PRINCIPAIS CATEGORIAS DE RECEITAS ---');
          var sortedReceitas = categoriasReceitas.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          for (var entry in sortedReceitas.take(5)) {
            int frequencia = frequenciaDescricoes[entry.key] ?? 0;
            contextBuffer.writeln('• ${entry.key}: R\$ ${entry.value.toStringAsFixed(2)} (${frequencia}x)');
          }
        }
        
        // Análise por cliente
        if (gastosPorCliente.isNotEmpty) {
          contextBuffer.writeln('\n--- GASTOS POR CLIENTE ---');
          var sortedClientesGastos = gastosPorCliente.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          for (var entry in sortedClientesGastos.take(5)) {
            contextBuffer.writeln('• ${entry.key}: R\$ ${entry.value.toStringAsFixed(2)}');
          }
        }
        
        if (receitasPorCliente.isNotEmpty) {
          contextBuffer.writeln('\n--- RECEITAS POR CLIENTE ---');
          var sortedClientesReceitas = receitasPorCliente.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          for (var entry in sortedClientesReceitas.take(5)) {
            contextBuffer.writeln('• ${entry.key}: R\$ ${entry.value.toStringAsFixed(2)}');
          }
        }
        
        // Análise mensal
        if (gastosPorMes.isNotEmpty) {
          contextBuffer.writeln('\n--- HISTÓRICO MENSAL DE GASTOS ---');
          var sortedMeses = gastosPorMes.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));
          
          for (var entry in sortedMeses.take(6)) {
            int ano = entry.key ~/ 100;
            int mes = entry.key % 100;
            double receita = receitasPorMes[entry.key] ?? 0;
            double saldo = receita - entry.value;
            contextBuffer.writeln('• $mes/$ano: Gasto R\$ ${entry.value.toStringAsFixed(2)} | Receita R\$ ${receita.toStringAsFixed(2)} | Saldo R\$ ${saldo.toStringAsFixed(2)}');
          }
        }
        
        // Transações mais recentes
        contextBuffer.writeln('\n--- ÚLTIMAS 20 TRANSAÇÕES ---');
        var recentTransactions = allTransactions.take(20);
        
        for (var transaction in recentTransactions) {
          String tipo = transaction.type == 'entrada' ? 'RECEITA' : 'DESPESA';
          String clientInfo = transaction.client != null ? ' (Cliente: ${transaction.client!.name})' : '';
          contextBuffer.writeln('• $tipo: R\$ ${transaction.amount.toStringAsFixed(2)} - ${transaction.description}$clientInfo - ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}');
        }
        
        // Padrões e insights
        contextBuffer.writeln('\n--- INSIGHTS FINANCEIROS ---');
        if (totalReceitas > 0 && totalDespesas > 0) {
          double porcentagemGasto = (totalDespesas / totalReceitas) * 100;
          contextBuffer.writeln('• Você gasta ${porcentagemGasto.toStringAsFixed(1)}% do que recebe');
        }
        
        if (frequenciaDescricoes.isNotEmpty) {
          var transacaoMaisFrequente = frequenciaDescricoes.entries
            .reduce((a, b) => a.value > b.value ? a : b);
          contextBuffer.writeln('• Transação mais frequente: ${transacaoMaisFrequente.key} (${transacaoMaisFrequente.value}x)');
        }
      }

      if (contextBuffer.isEmpty) {
        return 'Nenhum dado financeiro disponível no momento. Por favor, certifique-se de que você tem cartões e transações cadastrados.';
      }

      return contextBuffer.toString();
    } catch (e) {
      print('Erro ao processar dados financeiros: $e');
      return 'Erro ao processar dados financeiros.';
    }
  }
}