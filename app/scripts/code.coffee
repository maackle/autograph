window.goForth = ($)->
	root = null
	link = null
	node = null
	containerId = '#ultimate'
	w = $(containerId).width()
	h = $(containerId).height()
	console.log w, h
	force = d3.layout.force()
		.charge(-10000)
		.linkDistance(200)
		.linkStrength(1)
		.size([w, h])
		.on 'tick', ->
			link.attr("x1", (d) -> d.source.x )
				.attr("y1", (d) -> d.source.y )
				.attr("x2", (d) -> d.target.x )
				.attr("y2", (d) -> d.target.y )

			node.attr("cx", (d) -> d.x )
				.attr("cy", (d) -> d.y )


	update = ->
		nodes = flatten(root)
		links = d3.layout.tree().links(nodes)

		force.nodes(nodes).links(links).start()

		link = vis.selectAll('line.link')
			.data(links, (d) -> d.target.id)

		link.enter().insert('svg:line', '.node')
			.attr('class', 'link')
			.attr('x1', (d) -> d.source.x)
			.attr('y1', (d) -> d.source.y)
			.attr('x2', (d) -> d.target.x)
			.attr('y2', (d) -> d.target.y)

		link.exit().remove()

		node = vis.selectAll('circle.node')
			.data(nodes, (d) -> d.id)
			.style('fill', color)

		node.enter().append('svg:circle')
			.attr('class', 'node')
			.attr('cx', (d) -> d.x)
			.attr('cy', (d) -> d.y)
			.attr('r', (d) -> Math.sqrt(d.size) || 45)
			.style('fill', color)
			# .on('click', toggleChildren)
			.call(force.drag)

		node.exit().remove()

	toggleChildren = (d) ->
		if (d.children)
			d._children = d.children
			d.children = null
		else
			d.children = d._children
			d._children = null
		update()


	color = (d) ->
		if d._children 
			"#3182bd"
		else if d.children
			"#c6dbef"
		else 
			"#fd8d3c"

	flatten = (root) ->
		nodes = []
		i = 0

		recurse = (node) ->
			if (node.children) then node.children.forEach(recurse)
			if (!node.id) then node.id = ++i
			nodes.push(node)

		recurse(root)
		nodes

	vis = d3.select(containerId).append('svg:svg')
		.attr('class', 'svg-main')

	d3.json '/scripts/nodes.json', (json) ->
		root = json
		update()
