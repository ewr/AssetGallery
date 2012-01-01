module AssetGallery
  class AssethostAsset < ActiveResource::Base
    self.site = "http://#{AssetHost[:server]}/api/"
    self.element_name = 'asset'
    self.include_root_in_json = false

    def tag(size)
      if !self.tags
        return nil
      end

      self.tags.send(size.to_s).html_safe
    end

    def asset
      return self
    end

    #----------

    def url_domain 
      if !self.url || self.url == ''
        return nil
      end

      domain = URI.parse(self.url).host

      return domain
    end

    #----------

    class << self
        @@auth_token = AssetHost[:token]

        #----------

        def element_path(id, prefix_options = {}, query_options = nil)
          super(id, *apply_auth_token(prefix_options, query_options))
        end

        def collection_path(prefix_options = {}, query_options = nil)
          super(*apply_auth_token(prefix_options, query_options))
        end

        def apply_auth_token(prefix_options, query_options)
          if query_options
            [prefix_options, query_options.merge(:auth_token => @@auth_token)]
          else
            [prefix_options.merge(:auth_token => @@auth_token)]
          end
        end
      end
  end
end
