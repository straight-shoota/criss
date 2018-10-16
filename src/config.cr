class Crinja::Config
  include YAML::Serializable

  property source : String = "."
  property source_dir : String = "."
  property destination : String = "_site"
  property collections_dir : String = "."

  property plugins_dir : String = "_plugins"
  property layouts_dir : String = "_layouts"
  property data_dir : String = "_data"
  property includes_dir : String = "_includes"

  # property collections : Array(Collection::Config)
  #   "posts" => {
  #     property output : String = true
  #     property sort_by : String = "date"
  #     property sort_descending : String = true
  #     property drafts_dir : String = "_drafts"
  #   }
  # },

  # Handling Reading
  property include : Array(String) = [".htaccess"]
  property exclude : Array(String) = %w(
    Gemfile Gemfile.lock node_modules vendor/bundle/ vendor/cache/ vendor/gems/
    vendor/ruby/
  )
  property keep_files : Array(String) = [".git", ".svn"]
  property encoding : String = "utf-8"
  property markdown_ext : String = "markdown,mkdown,mkdn,mkd,md"

  # Filtering Content
  property future : Bool = false
  property unpublished : Bool = false

  # Plugins
  property whitelist : Array(String) = [] of String
  property plugins : Array(String) = [] of String

  # Conversion
  property highlighter : String = "rouge"
  property excerpt_separator : String = "\n\n"

  # Serving
  property detach : Bool = false # default to not detaching the server
  property port : String = 4000
  property host : String = "127.0.0.1"
  property show_dir_listing : Bool = true
  property livereload : Bool = true
  property livereload_port : String = 35729

  # Output Configuration
  property permalink : String = "date"
  property timezone : String = nil # use the local timezone

  property quiet : Bool = false
  property verbose : Bool = false
  property defaults : Array(String) = [] of String

  # property liquid
  #   property error_mode : String = "warn"
  #   property strict_filters : Bool = false
  #   property strict_variables : Bool = false
  # },

  # "kramdown"            => {
  #   property auto_ids : Bool = true
  #   property toc_levels : String = "1..6"
  #   property entity_output : String = "as_char"
  #   property smart_quotes : String = "lsquo,rsquo,ldquo,rdquo"
  #   property input : Bool = "GFM"
  #   property hard_wrap : Bool = false
  #   property footnote_nr : String = 1
  #   property show_warnings : Bool = false
end
