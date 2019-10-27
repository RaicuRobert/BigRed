const koa = require('koa');
const app = new koa();
const server = require('http').createServer(app.callback());
const WebSocket = require('ws');
const wss = new WebSocket.Server({server});
const Router = require('koa-router');
const cors = require('koa-cors');
const bodyParser = require('koa-bodyparser');
const convert = require('koa-convert');

app.use(bodyParser());
app.use(convert(cors()));
app.use(async (ctx, next) => {
  const start = new Date();
  await next();
  const ms = new Date() - start;
  console.log(`${ctx.method} ${ctx.url} ${ctx.response.status} - ${ms}ms`);
});


const router = new Router();
router.get('/', ctx => {
  ctx.response.body = 'I am server';
});


products = [
  {'name': 'Banana', 'category':'Fruit&Vegetables', 'quantity':7, 'barcode': '872353'},
  {'name': 'Tomato', 'category':'Fruit&Vegetables', 'quantity':6, 'barcode': '546742'},
  {'name': 'Orange', 'category':'Fruit&Vegetables', 'quantity':20, 'barcode': '913468'},
  {'name': 'Tesco British Chicken Breast Portions 650G', 'category':'Meat', 'quantity':7, 'barcode': '9163539'},
  {'name': 'Richmond 12 Thick Pork Sausages 681G', 'category': 'Meat', 'quantity':3, 'barcode': '091374'},
  {'name': 'Tesco Smoked Thick Cut Back Bacon 300G', 'category': 'Meat', 'quantity':5, 'barcode': '661083'},
  {'name':'Tesco Cinnamon Tear And Share Bun', 'category':'Bakery', 'quantity':10, 'barcode':'877755'},
  {'name':'Pagen Gifflar Cinnamon 260G', 'category':'Bakery', 'quantity':22, 'barcode':'683644'},
  {'name':'Tesco Portuguese Custard Tart 4 Pack', 'category':'Bakery', 'quantity':9, 'barcode':'542309'},
  {'name':'Tesco Cinnamon Swirl 2 Pack', 'category': 'Bakery', 'quantity':13, 'barcode': '786234'}
]

requestedProducts = []

const broadcast = (data) =>
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });

// GET ALL PRODUCTS
router.get('/all', ctx =>{
  ctx.response.body = products;
  ctx.response.status = 200;
});

// GET PRODUCTS IN A GIVEN CATEGORY
router.get('/category/:category', ctx =>{
  const category = ctx.params.category;
  console.log(category);
  prods = []
  for (var prod  of products)
    {
      // console.log(prod['category'])
      if (prod['category'] == category)
        prods.push(prod);
    }

  ctx.response.body = prods;
  ctx.response.status = 200;
});

//GET THE REQUESTED PRODUCTS IN A GIVEN CATEGORY
router.get('/requestedInCategory/:category', ctx =>{
  const category = ctx.params.category;
  console.log(category)
  prods = []
  for (var prod  of requestedProducts)
    {
      console.log(prod['category'])
      if (prod['category'] == category)
        prods.push(prod);
    }

  ctx.response.body = prods;
  ctx.response.status = 200;
});

//GET ALL THE REQUESTED PRODUCTS
router.get('/requested', ctx =>{
  ctx.response.body = requestedProducts;
  ctx.response.status = 200;  
});

// ADD A NEW PRODUCT 
router.post('/addProduct', ctx =>{
  const headers = ctx.request.body;
  console.log(headers);
  const name = headers.name;
  const category = headers.category;
  const quantity = headers.quantity;
  const barcode = headers.barcode;
  console.log('Adding product with name ' + name + ', category ' + category + ', quantity ' + quantity + ', barcode: ' + barcode);
  var newProd = {'name': name, 'category': category, 'quantity': quantity, 'barcode': barcode};
  products.push(newProd);
  ctx.response.status = 200;
});

//DELETE A PRODUCT
router.post('/delete', ctx =>{
  const parameters = ctx.request.body;
  console.log(ctx.request.headers);
  const name = parameters.name;
  console.log(parameters.quantity);
  const quantity = parseInt(parameters.quantity);
  console.log(quantity);
  // find the product
  for (var i = 0; i < products.length; i++){
    prod = products[i];
    if (prod['name'] == name){
      var currQuantity = prod['quantity'];
      if (currQuantity - quantity == 0)
        {
          products.splice(i,1);
          var requestedProd = {'name': prod['name'], 'category': prod['category'], 'quantity': quantity, 'barcode': prod['barcode']};
      var found = false;
      for (var req of requestedProducts){
        if (req['name'] == requestedProd['name']){
          req['quantity'] += requestedProd['quantity']
          found = true;
        }
      }
      if (found == false)
        requestedProducts.push(requestedProd);
        ctx.response.status = 200;
          return;
        }
      else
        prod['quantity'] = currQuantity - quantity;
      var requestedProd = {'name': prod['name'], 'category': prod['category'], 'quantity': quantity, 'barcode': prod['barcode']};
      var found = false;
      for (var req of requestedProducts){
        if (req['name'] == requestedProd['name']){
          req['quantity'] += requestedProd['quantity']
          found = true;
        }
      }
      if (found == false)
        requestedProducts.push(requestedProd);
    }
  }
  ctx.response.status = 200;
});




app.use(router.routes());
app.use(router.allowedMethods());

server.listen(4001);