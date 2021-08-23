# Criação de sessão e entrada SPIRE para o consumidor

```bash
# Atestar CAS
scone cas attest cas  -C -G --only_for_testing-trust-any --only_for_testing-debug --only_for_testing-ignore-signer

# Criar sessão
scone session create session.yaml

# Registrar entrada SPIRE
export SESSION_HASH=04f356e6ebd0a91e236fe1c802fff4bce9eb49732677c4e14e514b8938b75c1f
export SESSION_NAME=svid-session

./bin/spire-server entry create -parentID $AGENTE_ID \
        -spiffeID spiffe://lsd.ufcg.edu.br/consumidor \
        -selector svidstore:type:scone_cas_secretsmanager \
        -selector cas_session_hash:$SESSION_HASH \
        -selector cas_session_name:$SESSION_NAME
```