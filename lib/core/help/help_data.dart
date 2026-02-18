import 'package:flutter/material.dart';

/// A section inside a help topic (title + body paragraphs).
class HelpSection {
  const HelpSection({this.title, required this.paragraphs});
  final String? title;
  final List<String> paragraphs;
}

/// A single help topic (e.g. "Transações", "Orçamentos").
class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.sections,
    this.group,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<HelpSection> sections;
  /// Optional group key for grouping on the help list (e.g. 'getting_started', 'features', 'faq').
  final String? group;
}

/// All help content in one place. Content is in Portuguese (PT-BR).
class HelpData {
  HelpData._();

  static const String groupGettingStarted = 'getting_started';
  static const String groupFeatures = 'features';
  static const String groupFaq = 'faq';

  static List<HelpTopic> get allTopics => [
        _primeirosPassos,
        _transacoes,
        _orcamentos,
        _contas,
        _cartoes,
        _emprestimos,
        _contasFixas,
        _metas,
        _relatorios,
        _insights,
        _iaFinanceira,
        _configuracoes,
        _faq,
      ];

  static HelpTopic? topicById(String id) {
    try {
      return allTopics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<HelpTopic> topicsByGroup(String group) =>
      allTopics.where((t) => t.group == group).toList();

  static List<HelpTopic> search(String query) {
    if (query.trim().isEmpty) return allTopics;
    final lower = query.trim().toLowerCase();
    return allTopics.where((t) {
      if (t.title.toLowerCase().contains(lower)) return true;
      for (final s in t.sections) {
        if (s.title != null && s.title!.toLowerCase().contains(lower)) return true;
        for (final p in s.paragraphs) {
          if (p.toLowerCase().contains(lower)) return true;
        }
      }
      return false;
    }).toList();
  }

  // ----- Topic definitions -----

  static const HelpTopic _primeirosPassos = HelpTopic(
    id: 'primeiros_passos',
    title: 'Primeiros passos',
    icon: Icons.rocket_launch_outlined,
    group: groupGettingStarted,
    sections: [
      HelpSection(
        title: 'Visão geral',
        paragraphs: [
          'O Fin Pessoal ajuda você a controlar receitas, despesas, contas, orçamentos e metas em um só lugar.',
          'Na tela Início você vê o saldo total, receitas e despesas do mês e atalhos para as principais funções.',
        ],
      ),
      HelpSection(
        title: 'Começando',
        paragraphs: [
          'Crie pelo menos uma conta em Contas (ex.: Carteira, Banco). Depois registre transações em Transações (receitas e despesas) para ver o saldo e os relatórios atualizados.',
          'Use Orçamentos para definir limites por categoria e Metas para objetivos de economia.',
        ],
      ),
    ],
  );

  static const HelpTopic _transacoes = HelpTopic(
    id: 'transacoes',
    title: 'Transações',
    icon: Icons.list_alt,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'O que são transações',
        paragraphs: [
          'Transações são movimentações de dinheiro: receitas (entrada) ou despesas (saída). Cada uma tem valor, data, conta, categoria e opcionalmente uma nota.',
        ],
      ),
      HelpSection(
        title: 'Como adicionar',
        paragraphs: [
          'Na tela Transações, toque no botão + para abrir o formulário. Escolha o tipo (Receita ou Despesa), informe valor, data, conta e categoria. Salve.',
        ],
      ),
      HelpSection(
        title: 'Editar ou excluir',
        paragraphs: [
          'Toque em uma transação na lista para editar ou excluir. Alterações refletem no saldo da conta e nos relatórios.',
        ],
      ),
    ],
  );

  static const HelpTopic _orcamentos = HelpTopic(
    id: 'orcamentos',
    title: 'Orçamentos',
    icon: Icons.pie_chart_outline,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'O que são orçamentos',
        paragraphs: [
          'Orçamentos definem um limite de gastos por categoria em um período (por exemplo, Alimentação no mês). O app ajuda a acompanhar se você está dentro do limite.',
        ],
      ),
      HelpSection(
        title: 'Criando um orçamento',
        paragraphs: [
          'Em Orçamentos, toque em + e escolha a categoria e o valor máximo. Você pode definir orçamentos mensais ou por outro período, conforme a tela permitir.',
        ],
      ),
      HelpSection(
        title: 'Acompanhamento',
        paragraphs: [
          'Na lista de orçamentos você vê quanto já foi gasto e quanto resta. Assim fica mais fácil evitar estouros.',
        ],
      ),
    ],
  );

  static const HelpTopic _contas = HelpTopic(
    id: 'contas',
    title: 'Contas',
    icon: Icons.account_balance_wallet,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'O que são contas',
        paragraphs: [
          'Contas representam onde seu dinheiro está: Carteira, conta corrente, poupança, etc. O saldo de cada conta é calculado pelas transações vinculadas a ela.',
        ],
      ),
      HelpSection(
        title: 'Criar e editar',
        paragraphs: [
          'Em Contas, use + para criar uma nova conta (nome e valor inicial opcional). Toque em uma conta para editar ou excluir.',
        ],
      ),
      HelpSection(
        title: 'Saldo total',
        paragraphs: [
          'O saldo total na Início é a soma dos saldos de todas as contas.',
        ],
      ),
    ],
  );

  static const HelpTopic _cartoes = HelpTopic(
    id: 'cartoes',
    title: 'Cartões',
    icon: Icons.credit_card,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Cartões de crédito',
        paragraphs: [
          'Aqui você cadastra cartões de crédito e acompanha faturas, limite e vencimento. As despesas do cartão podem ser lançadas como transações vinculadas ao cartão.',
        ],
      ),
      HelpSection(
        title: 'Uso',
        paragraphs: [
          'Adicione cada cartão com nome, limite e dia de fechamento/vencimento. Use a tela para ver o que já está na fatura e evitar gastos além do limite.',
        ],
      ),
    ],
  );

  static const HelpTopic _emprestimos = HelpTopic(
    id: 'emprestimos',
    title: 'Empréstimos',
    icon: Icons.handshake,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Controle de empréstimos',
        paragraphs: [
          'Registre empréstimos que você fez ou que tomou: valor, parcelas, datas. Acompanhe o que já foi pago e o saldo devedor.',
        ],
      ),
      HelpSection(
        title: 'Parcelas',
        paragraphs: [
          'Cada parcela paga pode ser registrada para manter o histórico e o saldo atualizado.',
        ],
      ),
    ],
  );

  static const HelpTopic _contasFixas = HelpTopic(
    id: 'contas_fixas',
    title: 'Contas fixas',
    icon: Icons.receipt_long,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'O que são contas fixas',
        paragraphs: [
          'Contas fixas são despesas recorrentes (aluguel, luz, assinaturas). Cadastre uma vez com valor e vencimento e o app ajuda a lembrar e a lançar as parcelas.',
        ],
      ),
      HelpSection(
        title: 'Lembretes',
        paragraphs: [
          'Se as notificações estiverem ativas nas Configurações, você pode receber avisos quando uma conta fixa estiver próxima do vencimento.',
        ],
      ),
    ],
  );

  static const HelpTopic _metas = HelpTopic(
    id: 'metas',
    title: 'Metas',
    icon: Icons.flag,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Metas de economia',
        paragraphs: [
          'Defina um objetivo (valor e data desejada). O app mostra quanto falta e sugere quanto guardar por mês. Você pode registrar aportes para acompanhar o progresso.',
        ],
      ),
      HelpSection(
        title: 'Lembretes',
        paragraphs: [
          'Com notificações ativadas, você pode receber lembretes de metas para não perder o foco.',
        ],
      ),
    ],
  );

  static const HelpTopic _relatorios = HelpTopic(
    id: 'relatorios',
    title: 'Relatórios',
    icon: Icons.analytics_outlined,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'O que você vê',
        paragraphs: [
          'Na tela Relatórios você escolhe um período (este mês, últimos 3, 6 ou 12 meses) e vê um resumo de receitas, despesas e saldo, além de gráficos de barras (por mês) e de pizza (despesas por categoria).',
        ],
      ),
      HelpSection(
        title: 'Atualização',
        paragraphs: [
          'Use puxar para atualizar para recarregar os dados com base nas suas transações.',
        ],
      ),
    ],
  );

  static const HelpTopic _insights = HelpTopic(
    id: 'insights',
    title: 'Insights',
    icon: Icons.lightbulb_outline,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Insights financeiros',
        paragraphs: [
          'A tela Insights oferece análises e dicas com base nos seus dados: gastos por categoria, tendências e sugestões para melhorar suas finanças.',
        ],
      ),
    ],
  );

  static const HelpTopic _iaFinanceira = HelpTopic(
    id: 'ia_financeira',
    title: 'IA financeira',
    icon: Icons.smart_toy_outlined,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Assistente inteligente',
        paragraphs: [
          'A IA financeira é um assistente que responde perguntas e dá sugestões com base nas suas transações, orçamentos e metas. Use para tirar dúvidas ou pedir resumos.',
        ],
      ),
    ],
  );

  static const HelpTopic _configuracoes = HelpTopic(
    id: 'configuracoes',
    title: 'Configurações',
    icon: Icons.settings,
    group: groupFeatures,
    sections: [
      HelpSection(
        title: 'Tema',
        paragraphs: [
          'Escolha entre tema claro, escuro ou seguir o sistema.',
        ],
      ),
      HelpSection(
        title: 'Notificações',
        paragraphs: [
          'Ative ou desative lembretes gerais, lembretes de contas fixas e de metas.',
        ],
      ),
      HelpSection(
        title: 'Geral',
        paragraphs: [
          'Moeda: atualmente o app usa Real (BRL).',
          'Redefinir onboarding: ative o switch para ver a tela de boas-vindas novamente ao reabrir o app.',
        ],
      ),
    ],
  );

  static const HelpTopic _faq = HelpTopic(
    id: 'faq',
    title: 'Perguntas frequentes',
    icon: Icons.help_outline,
    group: groupFaq,
    sections: [
      HelpSection(
        title: 'Meus dados são seguros?',
        paragraphs: [
          'Os dados ficam armazenados no seu dispositivo. Não enviamos suas informações financeiras para servidores externos sem sua autorização.',
        ],
      ),
      HelpSection(
        title: 'Como faço backup?',
        paragraphs: [
          'O backup depende da plataforma (iOS/Android). Use o backup do sistema ou exporte relatórios/transações quando a opção estiver disponível.',
        ],
      ),
      HelpSection(
        title: 'Posso usar em mais de um aparelho?',
        paragraphs: [
          'Cada instalação mantém seus próprios dados locais. Sincronização entre dispositivos pode ser oferecida em versões futuras.',
        ],
      ),
      HelpSection(
        title: 'Onde encontro a Central de Ajuda?',
        paragraphs: [
          'Acesse por Mais → Ajuda ou por Configurações → Ajuda. Aqui você encontra todos os tópicos e pode buscar por palavra-chave.',
        ],
      ),
    ],
  );
}
