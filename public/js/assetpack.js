window.addEventListener('load', function(e) {
  console.log(document);
  if(location.href.indexOf('present=1') > 0) {
    impress().init();
  }
  else {
    var elems = document.querySelectorAll('.note, .menu');
    for(i = 0; i < elems.length; i++) {
      elems[i].style.display = "block";
    }
  }
});
