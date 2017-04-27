/*
 This tag renders the whole CIMDraw application, handling routing logic.

 Copyright 2017 Daniele Pala <daniele.pala@rse-web.it>

 This file is part of CIMDraw.

 CIMDraw is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 CIMDraw is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with CIMDraw. If not, see <http://www.gnu.org/licenses/>.
*/

<cimDraw>
    <style>
     .center-block {
	 width: 600px;
	 text-align: center;
     }
     
     .diagramTools {
	 margin-bottom: 20px;
     }
     
     .app-container {
	 display: flex;
	 flex-flow: row nowrap;
     }     
    </style>
    
    <nav class="navbar navbar-default">
	<div class="container-fluid">
	    <div class="navbar-header">
		<a class="navbar-brand" href="">CIMDraw</a>
	    </div>
	    <div class="collapse navbar-collapse">
		<p class="navbar-text" id="cim-filename"></p>
		<select id="cim-diagrams" class="selectpicker navbar-left navbar-form"
			onchange="location = this.options[this.selectedIndex].value;" data-live-search="true">
		    <option disabled="disabled">Select a diagram</option>
		</select>
		<ul class="nav navbar-nav" id="cim-home-container">
		    <li class="dropdown">
			<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
			    File <span class="caret"></span>
			</a>
			<ul class="dropdown-menu">
			    <li><a href="">Open</a></li>
			    <li><a id="cim-save" download="file.xml">Save as...</a></li>
			    <li><a id="cgmes-save">Save as CGMES (NOT WORKING YET)...</a></li>
			    <li><a id="cgmes-download" download="file.zip" style="display: none;"></a></li>
			    <li class="disabled"><a id="cim-export" download="diagram.xml">Export current diagram</a></li>
			</ul>
		    </li>
		</ul>
	    </div>
	</div>
    </nav>
    
    <div class="container-fluid">
	<div class="row center-block" id="cim-local-file-component">
	    <div class="row center-block" id="cim-select-file">
		<div class="col-md-12">
		    <label class="control-label">Select File</label>
		</div>
	    </div>

	    <!-- File input plugin -->
	    <div class="row center-block">
		<div class="col-md-12" id="cim-file-input-container">
		    <form enctype="multipart/form-data" method="POST">
			<input id="cim-file-input" name="cim-file" type="file" class="file" data-show-preview="false" data-show-upload="false">
		    </form>
		</div>
	    </div>
	    
	    <div class="row center-block">
		<div class="col-md-12" id="cim-load-container">
		    <a class="btn btn-primary btn-lg" role="button" id="cim-load">Load</a>
		</div>
	    </div>
	    <div class="row center-block">
		<div class="col-md-12">
		    <label class="control-label">or</label>
		</div>
	    </div>
	    <div class="row center-block">
		<div class="col-md-12" id="cim-create-new-container">
		    <a class="btn btn-primary btn-lg" role="button" id="cim-create-new">Create new</a>
		</div>
	    </div>
	    
	</div>
	
	<div class="row diagramTools">
	    <div class="col-md-4"></div>	
	    <div class="col-md-4"></div>
	</div>

	<div class="row">
	    <div class="app-container col-md-12" id="app-container">
		<cimTree model={cimModel}></cimTree>
		<cimDiagram model={cimModel}></cimDiagram>
	    </div>
	</div>


	<!-- Modal for loading a specific diagram -->
	<div class="modal fade" id="newDiagramModal" tabindex="-1" role="dialog" aria-labelledby="newDiagramModalLabel">
	    <div class="modal-dialog" role="document">
		<div class="modal-content">
		    <div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			<h4 class="modal-title" id="newDiagramModalLabel">Enter a name for the new diagram</h4>
		    </div>
		    <div class="modal-body">
			<form>
			    <input type="text" class="form-control" id="newDiagramName" placeholder="untitled">
			</form> 
		    </div>
		    <div class="modal-footer">
			<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			<button type="button" class="btn btn-primary" id="newDiagramBtn">Create</button>
		    </div>
		</div>
	    </div>
	</div>

	<!-- Modal for loading diagram list -->
	<div class="modal fade" id="loadingModal" tabindex="-1" role="dialog" aria-labelledby="loadingDiagramModalLabel" data-backdrop="static">
	    <div class="modal-dialog" role="document">
		<div class="modal-content">
		    <div class="modal-body">
			<p id="loadingDiagramMsg">loading diagram...</p>
		    </div>
		</div>
	    </div>
	</div>
   
    </div>

    <script>
     "use strict";
     let self = this;
     self.cimModel = cimModel();
     let diagramsToLoad = 2;
     
     self.on("loaded", function() {
	 diagramsToLoad = diagramsToLoad - 1;
	 if (diagramsToLoad === 0) {
	     $("#loadingModal").modal("hide");
	     $("#loadingDiagramMsg").text("loading diagram...");
	     diagramsToLoad = 2;
	 }
     });
     
     self.on("mount", function() {
	 route.stop(); // clear all the old router callbacks
	 let cimFile = {};
	 let cimFileReader = {};
	 $(".selectpicker").selectpicker({container: "body"});

	 $("#cim-create-new-container").on("click", function() {
	     cimFile = {name: "new1"};
	     cimFileReader = null;
	     route("/" + cimFile.name + "/diagrams");
	 });
	 
	 // This is the initial route ("the home page").
	 route(function(name) {
	     // things to show
	     $("#cim-local-file-component").show();
	     // things to hide
	     $("#app-container").hide();
	     $("#cim-load-container").hide();
	     $("#cim-home-container").hide();
	     $(".selectpicker").selectpicker("hide");
	     // main logic
	     $("#cim-file-input").fileinput("reset");
	     $("#cim-file-input").fileinput("enable");
	     d3.select("#cim-diagrams").selectAll("option").remove();
	     d3.select("#cim-diagrams").append("option").attr("disabled", "disabled").html("Select a diagram");
	     d3.select("#cim-filename").html("");    
	     $(".selectpicker").selectpicker("refresh");
	     // initialize the fileinput component
	     $("#cim-file-input").fileinput();
	     // what to do when the user loads a file
	     $("#cim-file-input").on("fileloaded", function(event, file, previewId, index, reader) {	    
		 cimFile = file;
		 cimFileReader = reader;
		 $("#cim-load").attr("href", "#" + encodeURI(cimFile.name) + "/diagrams");
		 $("#cim-load-container").show();
	     });
	     // sometimes we must hide the 'load file' button
	     $('#cim-file-input').on('fileclear', function(event) {
	         $("#cim-load-container").hide();
	     });
	 });

	 // here we choose a diagram to display
	 route('/*/diagrams', function() {
	     // things to show
	     $("#cim-home-container").show();
	     $(".selectpicker").selectpicker("show"); 
	     // things to hide
	     $("#cim-local-file-component").hide();
	     $("#app-container").hide();
	     $("#cim-export").parent().addClass("disabled");
	     // main logic
	     $("#loadingDiagramMsg").text("loading CIM network...");
	     $("#loadingModal").off("shown.bs.modal");
	     $("#loadingModal").modal("show");
	     $("#loadingModal").on("shown.bs.modal", function(e) {	 
		 if (typeof(cimFile.name) !== "undefined") {
		     d3.select("#cim-filename").html(cimFile.name);
		     self.cimModel.load(cimFile, cimFileReader, function() {
			 loadDiagramList(cimFile.name);
			 $("#loadingModal").modal("hide");
		     }); 
		 } else {
		     let hashComponents = window.location.hash.substring(1).split("/");
		     let file = hashComponents[0];
		     self.cimModel.loadRemote("/" + file, function() {
			 loadDiagramList(file);
			 $("#loadingModal").modal("hide");
		     });
		 }
	     });
	 });

	 // here we show a certain diagram
	 route('/*/diagrams/*', function(file, name) {	
	     if (self.cimModel.activeDiagramName === decodeURI(name)) {
		 self.trigger("showDiagram", file, name);
		 return; // nothing to do;
	     }
	     $("#cim-local-file-component").hide();
	     $("#loadingDiagramMsg").text("loading diagram...");
	     $("#loadingModal").off("shown.bs.modal");
	     $("#loadingModal").modal("show");
	     $("#loadingModal").on("shown.bs.modal", function(e) {
		 loadDiagram(file, name);
	     });
	 });

	 // creates a new model if it doesn't exist, and shows a diagram.
	 function loadDiagram(file, name, element) {
	     self.cimModel.loadRemote("/" + file, showDiagram);
	     function showDiagram(error) {
		 if (error !== null) {
		     route("/");
		     return;
		 }
		 self.cimModel.selectDiagram(decodeURI(name));
		 loadDiagramList(decodeURI(file));
		 $('.selectpicker').selectpicker('val', decodeURI("#" + file + "/diagrams/" + name));
		 self.trigger("showDiagram", file, name, element);
		 $("#app-container").show();

		 // allow exporting a copy of the diagram 
		 $("#cim-export").on("click", function() {
		     let out = self.cimModel.export();
		     let blob = new Blob([out], {type : 'text/xml'});
		     let objectURL = URL.createObjectURL(blob);
		     $("#cim-export").attr("href", objectURL);
		 });
		 $("#cim-export").parent().removeClass("disabled");
	     };
	 };

	 function loadDiagramList(filename) {
	     $("#cim-save").off("click");
	     // allow saving a copy of the file as plain XML
	     $("#cim-save").on("click", function() {
		 let out = self.cimModel.save();
		 let blob = new Blob([out], {type : 'text/xml'});
		 let objectURL = URL.createObjectURL(blob);
		 $("#cim-save").attr("href", objectURL);
	     });
	     $("#cgmes-save").off("click");
	     // allow saving a copy of the file as CGMES
	     $("#cgmes-save").on("click", cgmesSave);
	     function cgmesSave() {
		 let out = self.cimModel.saveAsCGMES();
		 out.then(function(content) {
		     let objectURL = URL.createObjectURL(content);
		     $("#cgmes-download").attr("href", objectURL);
		     document.getElementById("cgmes-download").click();
		 });
	     };
	     // load diagram list
	     $(".selectpicker").selectpicker({container: "body"});
	     d3.select("#cim-diagrams").selectAll("option").remove();
	     d3.select("#cim-diagrams").append("option").attr("disabled", "disabled").html("Select a diagram");
	     $(".selectpicker").selectpicker("refresh");
	     d3.select("#cim-diagrams").append("option")
	       .attr("value", "#" + filename + "/createNew") 
	       .text("Generate a new diagram");
	     let diagrams = self.cimModel.getDiagramList();
	     for (let i in diagrams) {
		 d3.select("#cim-diagrams").append("option").attr("value", "#" + filename + "/diagrams/"+diagrams[i]).text(diagrams[i]);
	     }
	     $(".selectpicker").selectpicker("refresh");
	 };
	 
	 route("/*/diagrams/*/*", function(file, name, element) {
	     $("#cim-local-file-component").hide();
	     loadDiagram(file, name, element);
	 });

	 route("/*/createNew", function(file) {
	     $("#newDiagramModal").modal("show");
	     d3.select("#newDiagramBtn").on("click", function() {
		 let diagramName = d3.select("#newDiagramName").node().value;
		 let hashComponents = window.location.hash.substring(1).split("/");
		 let basePath = hashComponents[0] + "/diagrams/";
		 let fullPath = basePath + diagramName;
		 $('#newDiagramModal').modal("hide");
		 route(fullPath);
	     });
	 });

	 // start router
	 route.start(true);
     });
    </script>
</cimDraw>
