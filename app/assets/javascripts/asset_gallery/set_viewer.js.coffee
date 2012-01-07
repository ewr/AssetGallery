#= require asset_gallery/agbase
#= require asset_gallery/strftime
#= require underscore
#= require backbone
#= require asset_gallery/models

class AssetGallery.SetViewer
    DefaultOptions:
        el:     ""
        path:   "/"

    #----------

    constructor: (assetdata,options) ->
        @options = _(_({}).extend(@DefaultOptions)).extend( options || {} )
        
        # add in events
        _.extend(this, Backbone.Events)
        
        # -- load assets -- #
        
        console.log "Loading assets: ", assetdata
        @assets = new AssetGallery.Models.Assets(assetdata)
        
        # -- initialize our views -- #
        
        # our strategy is to create a list and add each of our views as items
        # we need to know a width, with will be assets+1 * width of our container
        
        @cwidth = $(@options.el).width()
        totalw = @cwidth * ( @assets.size() + 1 )
        @ul = $("<ul/>",style:"position:relative;width:#{totalw}px;height:400px")
        $(@options.el).html @ul

        # Set View
        @setView = new SetViewer.SetView collection:@assets
        @ul.append $("<li/>",
            id:     "ag_sv_set",
            style:  "width:#{@cwidth}px;left:0"
        ).html @setView.render().el

        # Asset Detail View
        @assets.each (m,idx) =>
            dv = new SetViewer.DetailView model:m
            @ul.append $("<li/>",
                id:     "ag_sv_a#{m.get('id')}",
                style:  "width:#{@cwidth}px;left:#{(idx+1)*@cwidth}px"
            ).html dv.render().el
            
        # Slideshow View
        @slidenav = new SetViewer.NavigationLinks
            total: @assets.size()
            current: 0
        
        @slides = new SetViewer.SlideController 
            collection: @assets
            nav: @slidenav
                        
        $("body").append @slides.render().el

        # -- set up our router -- #
        
        @router = new SetViewer.Router()
        
        @router.bind "route:index",     => @_viewIndex()
        @router.bind "route:slide",     (id) => @_viewSlide(id)
        @router.bind "route:detail",    (id) => @_viewDetail(id)
        
        # attach navigation listeners
        @assets.bind "clickSetAsset", (model) => @router.navigate("/#{model.get('id')}/",true)
        @assets.bind "clickToSet", => @router.navigate("/",true)
        
        @assets.bind "clickPrev", (m) => 
            if @assets.indexOf(m) > 0
                target = @assets.at( @assets.indexOf(m) - 1 )
                @router.navigate("/#{target.get('id')}/detail",true)
            else
                @router.navigate('/',true)
                
        @assets.bind "clickNext", (m) =>
            if @assets.indexOf(m) + 1 < @assets.size()
                target = @assets.at( @assets.indexOf(m) + 1 )
                @router.navigate("/#{target.get('id')}/detail",true)
            else
                @router.navigate('/',true)
                
        @slides.bind "slide", (idx) =>
            # set nav
            @slidenav.setCurrent(idx)
            
            # set our URL back to the base slideshow. don't route off of it
            @router.navigate("/")
            
        # kick off routing
        Backbone.history.start({pushState: true,root: @options.path})
        console.log "launching routing"

    #----------
    
    slideTo: (idx) ->
        console.log "slideTo #{idx}: #{ -(idx*@cwidth) }"
        @ul.stop().animate {left: -(idx*@cwidth)}, "slow"        
        
    #----------
        
    _viewIndex: (id=null) ->
        console.log "rendering index"
        @slides.hide()
        @slideTo(0)
        
    #----------
    
    _viewSlide: (id) ->
        console.log "rendering slide for #{id} -- #{@assets.indexOf( @assets.get id )}"
        @slides.show @assets.indexOf( @assets.get id )
        
    #----------    
        
    _viewDetail: (id) ->
        console.log "rendering detail for #{id}"
        @slides.hide()
        @slideTo @assets.indexOf( @assets.get id )+1
        
    #----------    
            
    @Router:
        Backbone.Router.extend
            routes:
                '/:id/detail':  "detail"
                '/:id/':        "slide"
                '/':            "index"
                '':             "index"
                
            detail: ->
                
            slide: ->
                
            index: ->
                
    #----------
    
    @SlideView:
        Backbone.View.extend
            tagName: 'li'
            className: "slide"
                
            template:
                '''
                <div class="ag_slide_text" style="width:<%= width %>px">
                    <div class="credit"><%= credit %></div>
                    <p><%= caption %></p>
                </div>
                '''
                            
            #----------
                
            initialize: ->
                @controller = @options.controller
                @hidden = @options.hidden
                @index = @options.index
                
            #----------    
                
            render: ->
                # --  determine which image to load based on size -- #
                
                # sort of sizes hash
                sizes = @model.get("sizes")
                _(sizes).each (v, k) => v.key = k 
                sizes = _(sizes).sortBy (v) -> -v.width                
                
                # now take the first size that fits
                @imgSize = _(sizes).find (v,i) =>
                    if v.width < $(@el).width()
                        # take it
                        return true
                    else
                        return false
                        
                console.log "using imgSize of ", @imgSize
                
                # -- render text elements -- #
                
                # we have to render twice...  once to hidden and once to @el. 
                # this allows us to get dimensions
                
                # create temp element and render
                tmp = $ "<div/>"
                
                $(tmp).html _.template @template,
                    credit:     @model.get("owner")
                    caption:    @model.get("caption")
                    width:      @imgSize.width
                    
                @hidden.append tmp
                
                # get dimensions
                @textHeight = $(tmp).height()
                @imgHeight = $(@el).height() - @textHeight
                
                # and remove...
                $(tmp).detach()
                
                # now render caption and credit for real
                $(@el).html _.template @template, 
                    credit:     @model.get("owner")
                    caption:    @model.get("caption")
                    width:      @imgSize.width
                                    
                @
                
            #----------
                
            loadImage: ->
                if @controller.current == @index then $(@el).fadeOut() else $(@el).hide()
                                
                # -- now load -- #
                
                @img = $ "<img/>", src:@model.get("urls")[@imgSize.key]
                
                @hidden.prepend @img
                
                @img.load (evt) =>
                    # -- size image -- #
                    scale = 1
                    console.log "img w/h is", @img.width(), @img.height()
                    console.log "el w/h is ",$(@el).width(),@imgHeight
                    if @img.width() > $(@el).width()
                        scale = $(@el).width() / @img.width()
                        
                    if @img.height() > @imgHeight
                        vs = @imgHeight / @img.height()
                        scale = if scale < vs then scale else vs
                        
                    console.log("scaling slide to ",scale)
                        
                    w = @img.width()
                    h = @img.height()    
                    @img.css "width", w * scale 
                    @img.css "height", h * scale 
                                        
                    # -- center -- #
                    
                    @img.css "margin-left", ($(@el).width() - @img.width())/2
                    @img.css "margin-top", (@imgHeight - @img.height())/2
                    
                    # -- add to our element -- #
                    
                    @img.detach()                    
                    $(@el).prepend @img
                    
                    if @controller.current == @index then $(@el).fadeIn('slow') else $(@el).show()
                    
                    # -- tell the loader that we're done -- #
                    
                    @trigger "imgload"
            
        
    @SlideController:
        Backbone.View.extend
            className: "ag_slide_controller"

            initialize: ->
                @visible = false
                $(@el).hide()
                
                # -- create hidden element for dimensioning -- #
                @hidden = $ "<div/>", style:"position:absolute; top:-10000px; width:0px; height:0px;"
                $('body').append @hidden

                @slides = []

                @collection.each (a,idx) => 
                    s = new SetViewer.SlideView model:a, controller:@, hidden:@hidden, index:idx
                    @slides[idx] = s
                
                @queued = []
                @loaded = []
                @active = false

                @current = null
                
                $(window).bind "keydown", (evt) => @_keyhandler(evt)

            #----------

            render: () ->
                # -- grab window size for setting bounds -- #
                
                @wW = $(window).width()
                @wH = $(window).height()
                
                $(@el).attr "tabindex", -1

                # set our element to be the full size of our window
                $(@el).css "width", @wW+"px"
                $(@el).css "height", @wH+"px"

                totalw = @collection.length * @wW

                # check if slide0 has a right margin, and adjust width accordingly
                if @options.margin
                    totalw = totalw + @collection.length * @options.margin

                # available height defaults to slide height
                svheight = @wH

                if @options.nav
                    # render the nav in hidden to get its height
                    $(@options.nav.el).css "width", @wW+"px"
                    $(@hidden).append @options.nav.el                    
                    @options.nav.render()

                    navh = $(@options.nav.el).outerHeight()

                    # add nav height to slideview height
                    svheight -= navh
                    
                    # now detach it from hidden and drop it back into slides
                    $(@options.nav.el).detach()
                    $(@el).html @options.nav.el

                # create view tray
                @view = $ '<ul/>', style:"position:relative;width:#{totalw}px;height:#{svheight}px"

                # drop view into element
                $(@el).prepend @view

                # add our slides                
                _(@slides).each (s,idx) => 
                    s.bind "imgload", => @_loaded s, idx
                    $(s.el).css "width", @wW+"px"
                    $(s.el).css "height", svheight+"px"                    
                    $(s.el).css "left", @wW*idx + (@options.margin||0)*idx + "px"

                    $(@view).append s.render().el

                # create our load queue
                #@queueSlides _.range 0,4 

                @
                
            #----------

            _keyhandler: (e) ->
                if @visible
                    # is this a keypress we care about?
                    if e.which == 27
                        @hide()
                    else if e.which == 37
                        @slideBy(-1)
                    else if e.which == 39
                        @slideBy(1)

            #----------
            
            show: (idx=@current) ->
                if !@visible
                    console.log "prepared to show slide #{idx}: ", $(@slides[idx].el).css "left"
                    # don't animate.  just update our css
                    @view.css "left", "-#{$(@slides[idx].el).css "left"}"
                    @current = idx
                    
                    @trigger "slide", idx
                    @_updateLoadQueue()
                    
                    $(@el).fadeIn()
                    
                    @visible = true
                else
                    # if show gets called when we're already visible, just 
                    # treat it like slideTo
                    @slideTo(idx)
            
            #----------
            
            hide: ->
                if @visible
                    $(@el).fadeOut()
                    @visible = false
            
            #----------

            slideTo: (idx) ->                
                # figure out where slide[idx] is at
                @view.stop().animate {left: "-#{$(@slides[idx].el).css("left")}"}, "slow"
                @current = idx

                @trigger "slide", idx

                @_updateLoadQueue()

            #----------

            slideBy: (idx) ->
                t = @current + idx

                if @slides[t]
                    @slideTo(t)

            #----------

            queueSlides: (indexes...) -> 
                _(_(indexes).flatten()).each (i) =>
                    if !@loaded[i] || @loaded[i] == 0 && !_(@queued).contains(i)
                        console.log "queuing #{i}"
                        @queued.push i

                if !@active
                    @_fireUpQueue()

            #----------

            _updateLoadQueue: ->
                if !@loaded[@current] || @loaded[@current] == 0
                    @queued.unshift @current

                toQueue = []
                _(_.range(@current+1,@current+4)).each (i) => toQueue.push(i) if @slides[i] 
                _(_.range(@current-2,@current)).each (i) => toQueue.push(i) if @slides[i]

                @queueSlides toQueue

            #----------

            _fireUpQueue: ->
                return false if !@queued || @queued.length == 0

                console.log "_fireUpQueue with queue of #{@queued}"

                i = @queued.shift()
                s = @slides[i]

                if !@loaded[i] || @loaded[i] == 0
                    console.log "triggering load on #{i}"
                    @loaded[i] = 1
                    @active = i
                    s.loadImage()
                else
                    @_fireUpQueue()

            #----------

            _loaded: (s,idx) ->
                console.log "got _loaded for #{idx}"
                @loaded[idx] = 2

                if @active == idx
                    @active = null
                    @_fireUpQueue()

    #----------

    @NavigationLinks:
        Backbone.View.extend
            className: "ag_slide_nav"

            events: 
                'click button': '_buttonClick'

            template:
                '''
                <div style="width: 15%;">
                    <button <% print(prev ? "data-idx='"+prev+"' class='prev-arrow'" : "class='disabled prev-arrow'"); %> >Prev</button>
                </div>
                <div class="buttons" style="width:70%;"></div>
                <div style="width: 15%">
                    <button <% print(next ? "data-idx='"+next+"' class='next-arrow'" : "class='disabled next-arrow'"); %> >Next</button>
                </div>
                <br style="clear:both;line-height:0;height:0"/>
                '''

            #----------

            initialize: ->
                @total = @options.total
                @current = Number(@options.current) + 1

                @render()

            #----------

            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx) - 1
                    console.log "nav trigger slide to #{idx}"
                    @trigger "slide", idx

            #----------

            setCurrent: (idx) ->
                @current = Number(idx) + 1
                console.log "nav set current to #{@current}"
                @render()

            #----------

            render: ->
                buttons = _([1..@total]).map (i) =>
                    $("<button/>", {"data-idx":i, text:i, class:if @current == i then "current" else ""})[0]

                $(@el).html _.template @template, 
                    current:    @current, 
                    total:      @total,
                    prev:       if @current - 1 > 0 then @current - 1 else null
                    next:       if @current + 1 <= @total then @current + 1 else null

                @$(".buttons").html buttons
        
                    
    #----------
    
    @DetailView:
        Backbone.View.extend
            template:
                """
                <div class="ag_W" style="width: <%= sizes.wide.width %>px;">
                	<%= tags.wide %>
                	<div class="ag_credit">
                		<%= owner %>
                	</div>
                </div>

                <h2><%= title %></h2>

                <p><%= caption %></p>

            	<p><b>Taken:</b> <%= new Date(taken_at).strftime("%A, %B %-d, %Y, at %-I:%M%p") %> by <%= owner %></p>
            	
            	<button class="ag_return">Return to Set</button>
            	    
            	<button class="ag_prev">Previous</button>
            	<button class="ag_next">Next</button>
                """
                
            events:
                "click button.ag_return": "_click"
                "click button.ag_prev": "_clickPrev"
                "click button.ag_next": "_clickNext"
                    
            initialize: ->
                
            _click: ->
                @model.trigger "clickToSet"
            
            _clickPrev: ->
                @model.trigger "clickPrev", @model 

            _clickNext: ->
                @model.trigger "clickNext", @model
                
            render: ->
                $( @el ).html _.template @template, @model.toJSON() 
                
                @
    
    #----------

    @SetAssetView:
        Backbone.View.extend
            tagName: "li"

            tipTemplate:
                '''
                <h3><%= title %></h3>
        		<%= owner %>
        		<br/><%= size %>                
                '''
                
            events:
                'click button': "_click"
                
            initialize: ->
                @id = "ab_#{@model.get('id')}"
                $(@el).attr("data-asset-url",@model.get('url'))

                @render()
                
            _click: ->
                # clicked on...
                console.log "emiting click on ", @model.attributes
                @model.trigger("clickSetAsset",@model)
                
            render: ->
                $( @el ).html _.template @template, @model.toJSON() 
                $(@el).attr "draggable", true
                return this    
                
    @SetAssetViewGrid: 
        @SetAssetView.extend
            template:
                '''
                <button data-asset-url="<%= url %>" draggable="true"><%= tags.lsquare %></button>
                '''

    #----------
    
    @SetView:
        Backbone.View.extend
            tagName: "ul"
            className: "ag_set_assets"
                        
            initialize: ->
                @_views = {}
                
                @collection.bind "reset", => 
                    _(@_views).each (a) => $(a.el).detach()
                    @_views = {}
                    @render()
                    
                #@render()
                
            render: ->
                # set up views for each collection member
                @collection.each (a) => 
                    # create a view unless one exists
                    @_views[a.cid] ?= new SetViewer.SetAssetViewGrid model:a
                    #@_views[a.cid].bind "click", (a) => @trigger "click", a

                # make sure all of our view elements are added
                $(@el).append  _(@_views).map (v) -> v.el 
                
                @