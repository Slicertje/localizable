module Localizable

    def self.reset
        @default_locale_fetcher = nil
        @locale_to_string = Proc.new do |l|
            l.to_s
        end
    end

    def self.fetch_default_locale= (default_locale_fetcher)
        @default_locale_fetcher = default_locale_fetcher
    end

    def self.fetch_default_locale
        raise 'no default locale fetcher defined' unless @default_locale_fetcher
        @default_locale_fetcher.call
    end

    def self.locale_to_string (locale)
        @locale_to_string ||= Proc.new do |l|
            l.to_s
        end

        @locale_to_string.call(locale)
    end

    def self.locale_to_string= (locale_to_string)
        @locale_to_string = locale_to_string
    end

    def self.included(model)

        model.class_eval do
            extend ClassMethods
            include InstanceMethods
        end

    end

    module ClassMethods

        def localized_key (fieldname, type = String)
            key "#{fieldname}_values".to_sym, Hash
            localized_type[fieldname] = type

            self.class_eval <<-end_eval

                def #{fieldname} (locale = nil, default_text = '')
                    fetch_localized_value :#{fieldname}, locale, default_text
                end

                def #{fieldname}= (mapping)
                    store_localized_values :#{fieldname}, mapping
                end

            end_eval

        end

        def localized_type
            @localized_type ||= {}
        end

    end

    module InstanceMethods

        def fetch_localized_value (fieldname, locale, default_text)
            field = "#{fieldname}_values".to_sym
            locale ||= Localizable.fetch_default_locale
            locale_str = Localizable.locale_to_string(locale)

            if self[field].key?(locale_str)
                localized_type[fieldname].from_mongo(self[field][locale_str])
            else
                default_text
            end
        end

        def store_localized_values (fieldname, mapping)
            field = "#{fieldname}_values".to_sym

            mapping.each do |locale, value|
                self[field][locale] = localized_type[fieldname].to_mongo(value)
            end
        end

        def localized_type
            self.class.localized_type
        end


    end

end