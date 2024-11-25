const express = require('express');
const cors = require('cors'); // Adiciona o pacote CORS
const app = express();

// Permite o CORS para todas as origens
app.use(cors());

// Para que o Express entenda JSON
app.use(express.json());

let produtos = [
  { id: 1, nome: 'Produto A', precoCusto: 10, precoVenda: 20, categoria: 'Categoria 1' },
  { id: 2, nome: 'Produto B', precoCusto: 15, precoVenda: 30, categoria: 'Categoria 2' }
];

// Endpoints da API
app.get('/produtos', (req, res) => {
  res.json(produtos);
});

app.post('/produto', (req, res) => {
  const produto = req.body;
  produto.id = produtos.length + 1; // Gera o ID automaticamente
  produtos.push(produto);
  res.status(201).json(produto);
});

app.put('/produto/:id', (req, res) => {
  const { id } = req.params;
  const { nome, precoCusto, precoVenda, categoria } = req.body;
  let produto = produtos.find(p => p.id == id);
  if (produto) {
    produto.nome = nome;
    produto.precoCusto = precoCusto;
    produto.precoVenda = precoVenda;
    produto.categoria = categoria;
    res.json(produto);
  } else {
    res.status(404).json({ message: 'Produto não encontrado' });
  }
});

app.delete('/produto/:id', (req, res) => {
  const { id } = req.params;
  const index = produtos.findIndex(p => p.id == id);
  if (index !== -1) {
    produtos.splice(index, 1);
    res.status(200).json({ message: 'Produto excluído' });
  } else {
    res.status(404).json({ message: 'Produto não encontrado' });
  }
});

// Inicia o servidor
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
