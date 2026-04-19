# Guia para realizar a conexão com o banco de dados

Para fazer a conexão com o banco de dados use de exemplo o seguinte codigo de outra aplicação que utiliza o fastify ao invés de loopback como frammework do nodejs:

### Arquivo de conexão com o banco de dados
```
import 'dotenv/config'
import postgres from 'postgres'

const { PGHOST, PGDATABASE, PGUSER, PGPASSWORD, ENDPOINT_ID } = process.env;
const URL = `postgres://${PGUSER}:${PGPASSWORD}@${PGHOST}/${PGDATABASE}?options=project%3D${ENDPOINT_ID}`;

export const sql = postgres(URL, { ssl: 'require' });
```

Esse arquivo estabelece a conexão com o banco de dados postgresql, crie um arquivo para fazer a conexão com o banco de dados postgres porém mantenha a compatibilidade com o loopback e o node 24 que esta sendo utilizado dentro desse projeto. Faça a conexão com o banco de dados conforme o padrão de desenvolvimento utilizado para o loopback.

## Pontos importantes

- Sempre mantenha o clea code, criando funções coesas e apenas com uma ação unica.
- Pense que a arquitetura deve ser escalavel, preciso que os processos sejam padronizados para que possa ser replicados para outros casos de uso
- Sempre se preocupe com a compatibilidade do codigo com a stack que esta sendo utilizada, nesse caso nodejs v24 com Loopback