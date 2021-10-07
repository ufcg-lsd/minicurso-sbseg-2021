# Autenticando aplicações nativas da nuvem com identidades SPIFFE - SBSeg'21

Repositório com os recursos adicionais para o minicurso.

Resumo: A proposta deste minicurso é apresentar como aplicações nativas da nuvem são autenticadas utilizando o modelo confiança-zero e o padrão SPIFFE. Uma aplicação distribuída será utilizada como estudo de caso e seus microsserviços serão atestados de modo a receber identidades SPIFFE que permitirão autenticação mútua de acordo com os princípios de confiança zero. Para ilustrar as vantagens do modelo de confiança zero com identidades SPIFFE em ambientes de computação nativa da nuvem, usaremos tanto mecanismos de atestação baseados em Kubernetes, como mecanismos baseados em Intel SGX (usando o arcabouço SCONE).

## Demonstrações

- [Demonstração: produtor consumidor](https://github.com/ufcg-lsd/minicurso-sbseg-2021/blob/main/demo-produtor-consumidor/README.md)
- [Demonstração: ghostunnel](https://github.com/ufcg-lsd/minicurso-sbseg-2021/blob/main/demo-ghostunnel/README.md)
- [Demonstração: scone](https://github.com/ufcg-lsd/minicurso-sbseg-2021/blob/main/demo-scone/README.md)
