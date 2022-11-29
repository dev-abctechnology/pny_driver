# Persianas New York - Entregador

## Objetivo
Aplicativo com o objetivo de informar quando as entregas dos romaneios foram realizadas e informar se não foi entregue.

### principais funcionalidades (aplicativo)
* Listagem de romaneios atuais e passados do usuário.
* Visualização dos detalhes de romaneios previamente finalizados.
* Ordenar os pedidos de venda conforme a melhor rota a partir da localização atual do dispositivo com destino a rota informada pelo usuário.
* Ao chegar a cada destino, opção de selecionar entre entregue ou não entregue e fluxo especifico para cada situação.

### Sequência de navegação
#### login
* Campo de CPF/CNPJ.
* Campo de Senha.
* Botão de Login.

#### Home Page
##### aba 1
- Listagem dos romaneios ativos tendo como base a data atual.
##### aba 2
- Listagem dos romaneios finalizados e de datas anteriores.

#### Romaneio do dia
- Informações das entregas que serão realizadas.
- Botão de Iniciar viagem.

### Desenvolvimento
- [ ] Implementação da Assinatura digital
- [ ] Integrar APIs do google Maps para fazer roteirização
- [ ] Integrar com APP nativo de navegação
- [x] Melhorar background life cycle do app: Não é considerável rodar em background


### Questionamentos
* Q: O app irá manter o usuário logado? R:
* Como o app irá se comportar caso não haja conexão com a internet / jarvis ao entrar?
* Como o app irá se comportar caso não haja conexão com a internet / jarvis durante uma viagem do romaneio?