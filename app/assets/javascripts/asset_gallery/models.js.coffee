class AssetGallery.Models
    constructor: ->
        
    @Asset: Backbone.Model.extend
        urlRoot: "#{AssetHost.SERVER}/api/assets/"
                    
        #----------
        
        url: ->
            url = if this.isNew() then @urlRoot else @urlRoot + encodeURIComponent(@id)
            
            if AssetHost.TOKEN
                url = url + "?" + $.param({auth_token:AssetHost.TOKEN})
                
            url
            
        #----------
        
        slug: ->
            @get("title").replace(/\s+/g,"-").replace(/[^\w-_]+/g,"").toLowerCase()
        
        #----------
        
        chopCaption: (count=100) ->
            chopped = @get('caption')

            if chopped and chopped.length > count
                regstr = "^(.{#{count}}\\w*)\\W"
                chopped = chopped.match(new RegExp(regstr))

                if chopped
                    chopped = "#{chopped[1]}..."
                else
                    chopped = @get('caption')

            chopped
                
    #----------
    
    @Assets: Backbone.Collection.extend
        baseUrl: "/api/assets",
        model: @Asset
        
        # If we have an ORDER attribute, sort by that.  Otherwise, sort by just 
        # the asset ID.  
        comparator: (asset) ->
            asset.get("ORDER") || -Number(asset.get("id"))
        
        #----------

        
    @PaginatedAssets: @Assets.extend
        initialize: ->
            _.bindAll(this, 'parse','url')
            
            typeof(options) != 'undefined' || (options = {});
            @_page = 1;
            @_query = ''
            @per_page = 24
            @total_entries = 0
            
            this
        
        parse: (resp,xhr) ->
            @next_page = xhr.getResponseHeader('X-Next-Page')
            @total_entries = xhr.getResponseHeader('X-Total-Entries')
            console.log "Next page for assets is #{@next_page}"
            
            resp
            
        url: ->
            @baseUrl + "?" + $.param({page:@_page,q:@_query})
            
        query: (q=@_query) ->
            @_query = q if q?
            @_query
            
        page: (p=null) ->
            console.log('page is ',@_page,p)
            @_page = Number(p) if p? && p != ''
            @_page                
        
    #----------
