var toggler = document.getElementsByClassName("caret");
var i;

for (i = 0; i < toggler.length; i++) {
  toggler[i].addEventListener("click", function() {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
  });
}

/* Function to insert image dynamically */
var path = window.location.href;
var findFile = path.lastIndexOf("/");
var lastIndex = path.length;
var subString = path.substring(findFile+1,lastIndex);
var imageRootUrl = path.replace(subString,'html_images/modelRoot.png');
var imageLevelUrl = path.replace(subString,'html_images/modelLevel.png');
var root = document.getElementsByClassName("root");
var level = document.getElementsByClassName("level");
for (i = 0; i < root.length; i++)
{
root[i].src = imageRootUrl;
}
for (i = 0; i < level.length; i++)
{
level[i].src = imageLevelUrl;
}

/* Callback to open the html file in content pane */
function loadHtml(url, name, path,...args) {
    simulinkImageTags = '<div><p style="text-align:center";><mark><strong>Block Name:</strong>' + name + '</mark></p>' + '<p style="text-align:center";><mark><strong>BlockPath:</strong>' + path + '</mark></p>' + '<img src= ' + url + '>' + '</img></div>';
    var anchorTags = '';
    var imageTags = '';
    if (args.length != 0){
    anchorTags = '<div class="signalClass"><strong class="outputSignal">Output Signals</strong>';
    imageTags = '<div class="signalImageClass">';
    for(var i=0;i<args.length;i+=3){
    anchorTags = anchorTags+`<a class="anchor" href="#${args[i]}" title="${args[i+1]}"><img src="html_images/signal.png"><b>${args[i]}</b></a>`;
    imageTags = imageTags+`<img src="${args[i+2]}" id="${args[i]}" title="${args[i+1]}"></img>` 
    }
    anchorTags = anchorTags+'</div>'
    imageTags = imageTags+'</div>';
    }
    if (anchorTags != '' && imageTags != ''){
    combinedTags = '<button onclick="topFunction()" id="myBtn" title="Go to top">UP</button><div class="signalsContainer">' + anchorTags + simulinkImageTags + '</div>'
    simulinkImageTags = combinedTags+imageTags;
    }
    document.getElementById("mydiv").innerHTML=simulinkImageTags
}

// When the user scrolls down 20px from the top of the document, show the button

function scrollFunction() {
    var mybutton = document.getElementById("myBtn");
  if (document.getElementById("mydiv").scrollTop > 70 || document.documentElement.scrollTop > 70) {
    mybutton.style.display = "block";
  } else {
    mybutton.style.display = "none";
  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.getElementById("mydiv").scrollTop = 0;
  document.documentElement.scrollTop = 0;
}

function onload()
{
	dragElement( document.getElementById("seperator"), "H" );
}

// function is used for dragging and moving
function dragElement( element, direction, handler )
{
  // Two variables for tracking positions of the cursor
  var drag = { x : 0, y : 0 };
  var delta = { x : 0, y : 0 };
  /* if present, the handler is where you move the DIV from
     otherwise, move the DIV from anywhere inside the DIV */
  handler ? ( handler.onmousedown = dragMouseDown ): ( element.onmousedown = dragMouseDown );

  // function that will be called whenever the down event of the mouse is raised
  function dragMouseDown( e )
  {
    drag.x = e.clientX;
    drag.y = e.clientY;
    document.onmousemove = onMouseMove;
    document.onmouseup = function(){ 
document.onmousemove = document.onmouseup = null; 
}
  }

  // function that will be called whenever the up event of the mouse is raised
  function onMouseMove( e )
  {
    var currentX = e.clientX;
    var currentY = e.clientY;

    delta.x = currentX - drag.x;
    delta.y = currentY - drag.y;

    var offsetLeft = element.offsetLeft;
    var offsetTop = element.offsetTop;

	
	var first = document.getElementById("mynav");
	var second = document.getElementById("mydiv");
	var firstWidth = first.offsetWidth;
	var secondWidth = second.offsetWidth;
  if (direction === "H" ) // Horizontal
	{
		element.style.left = offsetLeft + delta.x + "px";
		firstWidth += delta.x;
		secondWidth -= delta.x;
	}
    drag.x = currentX;
    drag.y = currentY;
	first.style.width = firstWidth + "px";
	second.style.width = secondWidth + "px";
  }
}
