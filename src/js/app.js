App = {
  web3Provider: null,
  contracts: {},
  cur_account: null,
  accounts: null,
  init: async function() {
    // Load books.
    $.getJSON('../books.json', function(data) {
      var booksRow = $('#booksRow');
      var bookTemplate = $('#bookTemplate');

      for (i = 0; i < data.length; i ++) {
        bookTemplate.find('.panel-title').text(data[i].name);
        bookTemplate.find('img').attr('src', data[i].picture);
        bookTemplate.find('img').attr('width', 100);
        bookTemplate.find('img').attr('height', 200);
        bookTemplate.find('.author').text(data[i].breed);
        bookTemplate.find('.price').text(data[i].age);
        bookTemplate.find('.book-location').text(data[i].location);
        bookTemplate.find('.btn-borrow').attr('data-id', data[i].id);
        bookTemplate.find('.btn-return').attr('data-id', data[i].id);
        bookTemplate.find('.book-num').text(0);
        booksRow.append(bookTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      console.log(App.web3Provider);
    } else {
    // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('ropsten.infura.io/v3/20401dc3e9834236b08463d5ae5a4616');
    }
    web3 = new Web3(App.web3Provider);
    console.log(web3);
    return App.initContract();
  },

  initContract: function() {
    // load Library.json, which stores ABI of Library

    $.getJSON('Library.json', function(data) {
      console.log(data);
      // use the data from Library.json to create an interactive instance of TruffleContract
      App.contracts.Library = TruffleContract(data);
      // Set the provider for our contract
      App.contracts.Library.setProvider(App.web3Provider);
      // Use our contract to retrieve and mark the borrowed books
      return App.markBorrowed(); // retrieve past state at init time
    });

    $.getJSON('GangToken.json', function(data) {
      // use the data from Library.json to create an interactive instance of TruffleContract
      console.log(data);
      var GangArtifact = data;
      App.contracts.GangToken = TruffleContract(GangArtifact);
      // Set the provider for our contract
      App.contracts.GangToken.setProvider(App.web3Provider);
    });

    return App.bindEvents();
  },

  checkBalance: function(){
      App.cur_account = web3.eth.accounts[0];
      App.contracts.GangToken.deployed().then(function(instance){
      console.log(App.cur_account);
      var balance = instance.balanceOf(App.cur_account);
      balance.then(function(result){
        console.log(result)
        document.getElementById("mybalance").value = result;
      });
      });
    },

  bindEvents: function() {
    $(document).on('click', '.btn-borrow', App.handleBorrow);
    $(document).on('click', '.btn-return', App.handleReturn);
    $(document).on('click', '.btn-balance', App.checkBalance);
    $(document).on('click', '.btn-give', App.giveGang);
  },
  giveGang: function(){
    var recaddr = document.getElementById('recipient').value;
    var amount = Number(document.getElementById('amount').value);
      App.contracts.GangToken.deployed().then(function(instance){
          instance.modifyBalance(App.cur_accounts, amount, 1);
          instance.modifyBalance(recaddr, amount, 0);
    });
  },
  markBorrowed: function(users, account) {
    console.log(App.contracts);
    console.log(App.contracts.Library.deployed());
    App.contracts.Library.deployed().then(function(instance) {
      //return instance.counters;
      return instance.getCounters.call();
    }).then(function(counters) {
      console.log(counters);
      for (i = 0; i < counters.length; i++) {
        //console.log(counters[i]);
        if (counters[i][0] <= 0) { // all have been borrowed
          $('.panel-book').eq(i).find('#borrow').text('Borrowed').attr('disabled', true);
          $('.panel-book').eq(i).find('#return').text('Return').attr('disabled', false);
          //console.log('ok1');
          $('.panel-book').eq(i).find('#count').text(counters[i][0]);
        }
        else { // have some left
          $('.panel-book').eq(i).find('#borrow').text('Borrow').attr('disabled', false);
          $('.panel-book').eq(i).find('#return').text('Return').attr('disabled', false);
          //console.log('ok2');
          $('.panel-book').eq(i).find('#borrow').text('Borrow').attr('disabled', false);
          $('.panel-book').eq(i).find('#return').text('Return').attr('disabled', false);
          console.log('ok2');
          $('.panel-book').eq(i).find('#count').text(counters[i][0]);
          if (counters[i][1] <= 0) // no one still keeping this book
            $('.panel-book').eq(i).find('#return').text('Return').attr('disabled', true);
        }
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },


  handleBorrow: function(event) {
    event.preventDefault();
    var bookId = parseInt($(event.target).data('id'));
    var bookPrice = parseInt(document.getElementsByClassName("price")[bookId].innerText);
    console.log(bookId);
    console.log(bookPrice);
    // Now start borrowing
    App.contracts.Library.deployed().then(function(instance){
      return instance.borrow(bookId, bookPrice, {from:App.cur_account, gas:10000000});
    }).then(function(result){
        return App.markBorrowed();
    }).catch(function(err){
        window.alert("You don't have enough tokens!");
        console.log(err.message);
    });
  },

  handleReturn: function(event) {
    event.preventDefault();

    var bookId = parseInt($(event.target).data('id'));
    var libraryInstance;
    // get user account

    App.contracts.Library.deployed().then(function(instance) {
        // send transaction to return a book
      libraryInstance = instance;
      return libraryInstance.giveback(bookId, {from: App.cur_account});
      }).then(function(result) {
        return App.markBorrowed();
      }).catch(function(err) {
        var event = libraryInstance._library(function(error, result){
          console.log("Event are as following:-------");
          for(let key in result){
           console.log(key + " : " + result[key]);
          }
          if(error)
            console.log(error);
          console.log("Event ending-------");
        });

        console.log(err.message);
      });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
