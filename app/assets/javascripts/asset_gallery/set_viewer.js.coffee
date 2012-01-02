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

        # -- set up our router -- #
        
        @router = new SetViewer.Router()
        
        @router.bind "route:index",     => @_viewIndex()
        @router.bind "route:slide",     (id) => @_viewSlide(id)
        @router.bind "route:detail",    (id) => @_viewDetail(id)
        
        # attach navigation listeners
        @assets.bind "clickSetAsset", (model) => @router.navigate("/#{model.get('id')}/detail",true)
        @assets.bind "clickToSet", => @router.navigate("/",true)

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
        @slideTo(0)
        
    #----------
    
    _viewSlide: (id) ->
        console.log "rendering slide for #{id}"
        
    #----------    
        
    _viewDetail: (id) ->
        console.log "rendering detail for #{id}"
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
                """
                
            events:
                "click button.ag_return": "_click"
                    
            initialize: ->
                
            _click: ->
                @model.trigger("clickToSet")    
                
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