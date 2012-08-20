
function DynamicGraph (options) {
	var that = {
		container: options.container,
		startDisplayLevel: options.startDisplayLevel == null ? 50 : options.startDisplayLevel,
		step: options.step == null ? 5 : options.step,
		minDisplayedNodes: options.minNodes == null ? 3 : options.minNodes,
				
		width: options.width,
		height: options.height,
		
		drawNodeFunc: options.drawNode,
		drawEdgeFunc: options.drawEdge,
		
		draggable: options.draggable,
		selectionMode: options.selectionMode,
		
		handlers: options.handlers,
		
		selectedNodes: {},
		nodeH: {},
		displayedNodes: {},
		displayedEdges: {},
		totalNodes: 0,
		
		stage: null,
		particleSystem: null,
		nodeLayer: null,
		tooltipLayer: null,
		
		currentDisplayLevel: null,
		
		addNode: function (node) {
			if (!(node.id in that.displayedNodes)) {
				that.nodeLayer.add(node.prop);
				if (that.particleSystem.getNode(node.id) == null)
					node.sysNode = that.particleSystem.addNode(node.id, node.data);
				
				that.displayedNodes[node.id] = node;
			}
		},
		
		addEdge: function (edge) {
			var source = edge.source;
			var target = edge.target;
			if (source.id in that.displayedNodes && target.id in that.displayedNodes && !(edge.id in that.displayedEdges)) {
				that.nodeLayer.add(edge.prop);
				that.displayedEdges[edge.id] = edge;
				
				if (that.particleSystem.getEdges(source.id, target.id).length == 0)
					that.particleSystem.addEdge(source.id, target.id, edge.data);
			}
		},
		
		drawProps: function () {
			that.nodeLayer.draw();
		},
		
		draw: function () {
			that.stage.draw();
		},
		
		clear: function () {
			that.nodeLayer.removeChildren();
			that.tooltipLayer.removeChildren();
			
			for (var key in that.displayedNodes)
				that.particleSystem.pruneNode(that.displayedNodes[key].sysNode);
			
			that.selectedNodes = {};
			that.nodeH = {};
			that.displayedNodes = {};
			that.displayedEdges = {};
			that.totalNodes = 0;
			
			that.draw();
		},
		
		display: function (n) {
			// first clear the stage
			that.nodeLayer.removeChildren();
			that.displayedNodes = {};
			that.displayedEdges = {};
			
			that.currentDisplayLevel = n;
		
			var nodeH = that.nodeH;
			
			// add nodes and edges
			// add nodes, the edges will be added later, otherwise some will be omitted
			var nodesToDisplay = that.rankedNodeNames.slice(0, n);
			var edgesToDisplay = [];
			for (var i = 0; i < nodesToDisplay.length; i++) {
				var node = nodeH[nodesToDisplay[i]];
				var edges = node.edges;
				
				that.addNode(node);
				edgesToDisplay = edgesToDisplay.concat(edges);
			}
			
			// add the edges
			for (var i = 0; i < edgesToDisplay.length; i++)
				that.addEdge(edgesToDisplay[i]);
			
			that.nodeLayer.draw();
		},
		
		showMore: function () {
			var step = that.step;
			
			that.display(Math.min(that.totalNodes, that.currentDisplayLevel + step));
		},
		
		showLess: function () {
			var step = that.step;
			var rankedNodeNames = that.rankedNodeNames;
			
			var oldDisplayLevel = that.currentDisplayLevel;
			
			that.display(Math.max(that.minDisplayedNodes, that.currentDisplayLevel - step));
			
			var newDisplayLevel = that.currentDisplayLevel;
			var nodesToRemove = rankedNodeNames.slice(newDisplayLevel, oldDisplayLevel);
			for (var i = 0; i < nodesToRemove.length; i++)
				that.particleSystem.pruneNode(that.nodeH[nodesToRemove[i]].sysNode);
		},
		
		setData: function (data) {	
			that.clear();
			var allNodes = data.nodes;
			var allEdges = data.edges;
			
			var nodeDegrees = {};
			
			// rank the nodes
			for(var i = 0; i < allEdges.length; i++) {
				var edge = allEdges[i];
				var count = edge.data.count;
				
				if (edge.source == edge.target)
					nodeDegrees[edge.source] = (edge.source in nodeDegrees) ? nodeDegrees[edge.source] + count : count;
				else {
					nodeDegrees[edge.source] = (edge.source in nodeDegrees) ? nodeDegrees[edge.source] + count : count;
					nodeDegrees[edge.target] = (edge.target in nodeDegrees) ? nodeDegrees[edge.target] + count : count;
				}
			}
			
			var degNodeList = [];
			for(var i = 0; i < allNodes.length; i++) {
				var id = allNodes[i].id;
				var deg = 0;
				if(id in nodeDegrees){
					deg = nodeDegrees[id];
				}
				degNodeList.push([deg, id]);				
			}
			degNodeList.sort(function (a, b) {return b[0] - a[0];}); // sort in reverse order
			
			var rankedNodeNames = [];
			for(var i = 0; i < degNodeList.length; i++)
				rankedNodeNames.push(degNodeList[i][1]);
			
			var nodeH = {};
			var edgeH = {};
			
			// construct a node hash
			for (var i = 0; i < allNodes.length; i++) {
				var node = allNodes[i];
				node.neighboursSelected = 0;
				node.selected = false;
				
				var propNode = Node({
					id: node.id,
					data: node,
					draggable: that.draggable,
					selectionMode: that.selectionMode,
					graph: that,
					sysNode: that.particleSystem.addNode(node.id, node),
					handlers: that.handlers
				});
				
				propNode.data.prop = propNode.prop;
				nodeH[node.id] = propNode;
			}
			
			// construct an edge hash
			for (var i = 0; i < allEdges.length; i++) {
				var edge = allEdges[i];
				var source = nodeH[edge.source];
				var target = nodeH[edge.target];
				
				var propEdge = Edge({id: i + '',
					data: edge.data,
					drawFunc: that.drawEdgeFunc,
					source: source,
					target: target
				});
				
				propEdge.data.source = source;
				propEdge.data.target = target;
				
				if (source.edges.indexOf(propEdge) < 0) source.edges.push(propEdge);
				if (target.edges.indexOf(propEdge) < 0) target.edges.push(propEdge);
			}
			
			// remove all the nodes from the particle system
			for (var key in nodeH) {
				var sysNode = nodeH[key].sysNode;
				that.particleSystem.pruneNode(sysNode);
			}
			
			that.totalNodes = allNodes.length;
			that.nodeH = nodeH;
			that.edgeH = edgeH;
			that.rankedNodeNames = rankedNodeNames;
			that.display(that.startDisplayLevel);
		},
		
		
		init: function () {
			that.stage = new Kinetic.Stage({
				container: that.container,
				width: that.width,
				height: that.height
			});
			
			that.nodeLayer = new Kinetic.Layer();
			that.tooltipLayer = new Kinetic.Layer();
			
			that.stage.add(that.nodeLayer);
			that.stage.add(that.tooltipLayer);
			
			// create a particle system
			that.particleSystem = arbor.ParticleSystem(2000, 50, 0.5, true);
			that.particleSystem.parameters({gravity:true});
			that.particleSystem.parameters({precision:0.9});
			that.particleSystem.renderer = ArborRenderer({
				graph: that
			});
		}
	};
	
	that.init();
	
	return that;
}

function Node(opts) {
	var that = {
		id: opts.id,
		graph: opts.graph,
		data: opts.data,
		sysNode: opts.sysNode,
		drawFunc: opts.graph.drawNodeFunc,
		draggable: opts.draggable,
		selectionMode: opts.selectionMode,
		handlers: opts.handlers,
		
		edges: [],
		prop: null,
		
		select: function (select) {
			var data = that.data;
			var selectedNodes = that.graph.selectedNodes;
			
			if (select == data.selected) return;
			
			data.selected = select;
			selectedNodes[that.data.id] = select ? that : null;
			
			var neighbours = data.neighbours;
			for (var i = 0; i < neighbours.length; i++) {
				var neigh = neighbours[i];
				if (select) {
					neigh.neighboursSelected++;
				} else if(neigh.neighboursSelected > 0) {
					neigh.neighboursSelected--;
				}
			}
			
			// if using single selection mode => unselect prevoius nodes
			if (that.selectionMode == 'single') {
				for (var nodeId in selectedNodes) {
					if (nodeId != that.data.id && selectedNodes[nodeId] != null) {
						var node = selectedNodes[nodeId];
						node.data.selected = false;
						
						var neighbours = node.data.neighbours;
						for (var i = 0; i < neighbours.length; i++) {
							if (neighbours[i].neighboursSelected > 0)
								neighbours[i].neighboursSelected--;
						}
					}
				}
			}
			
			that.graph.drawProps();
		},
		
		addHandler: function (eventName, handler) {
			that.prop.on(eventName, function (event) {
				handler(event, that);
			});
		},
		
		init: function () {
			that.prop = new Kinetic.Shape({
				drawFunc: function () {
					if (that.data.pos == null) return;
					var context = this.getContext();
					that.drawFunc(context, that.data);
				}
			});
			
			if (that.draggable) {
				var prop = that.prop;
				prop.draggable(true);
				prop.on('dragmove', function (event) {
					event.cancelBubble = true;
	
					var pos = that.graph.stage.getUserPosition();
					var s = arbor.Point(pos.x, pos.y);
					var sys = that.graph.particleSystem;
					var p = sys.fromScreen(s);
	
					that.sysNode.p = {x: p.x, y: p.y};
				});
				prop.on('dragstart', function (event) {
					event.cancelBubble = true;
					that.sysNode.fixed = true;
					that.select(true);
				});
				prop.on('dragend', function (event) {
					event.cancelBubble = true;
					that.sysNode.fixed = false;
				});
			}
			
			if (that.selectionMode == 'single' || that.selectionMode == 'multiple') {
				that.prop.on("click", function (event) {
					event.cancelBubble = true;
					that.select(!that.data.selected);
				});
			}
			
			// add other handlers
			var handlers = that.handlers;
			var handNames = Object.keys(handlers);
			for (var i = 0; i < handNames.length; i++) {
				var hName = handNames[i];
				that.addHandler(hName, that.handlers[hName]);
			}
		}
	};
	
	that.init();
	
	return that;
};

function Edge(opts) {
	var that = {
		id: opts.id,
		data: opts.data,
		drawFunc: opts.drawFunc,
		source: opts.source,
		target: opts.target,
		
		prop: null,
		
		init: function () {
			that.prop = new Kinetic.Shape({
				drawFunc: function () {
					var context = this.getContext();
					that.drawFunc(context, that.data);
				}
			});
		}
	};
	
	that.init();
	return that;
}

function ArborRenderer(opts) {
	var that = {
		graph: opts.graph,
		
		particleSystem: null,
		
		init: function(system) {
			that.particleSystem = system;
			that.particleSystem.screenSize(that.graph.width, that.graph.height); 
			that.particleSystem.screenPadding(40);
		},
		
		redraw:function() {
			if (!that.particleSystem) return;

			that.particleSystem.eachNode(function(node, pt) {
				node.data.pos = pt;
				
				if (!node.data.prop.isDragging())
					node.data.prop.setPosition(pt.x, pt.y);
			});

			// draw the edges
			that.particleSystem.eachEdge(function(edge, pt1, pt2){
				//adjust the edge opacity based on the number of times it appears
				edge.data.source = edge.source.data;
				edge.data.target = edge.target.data;
				edge.data.pos1 = pt1;
				edge.data.pos2 = pt2;
			});
			
			that.graph.drawProps();
		}
	};
	
	return that;
}