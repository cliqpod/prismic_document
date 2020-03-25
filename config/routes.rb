PrismicDocument::Engine.routes.draw do
  root to: 'prismic_document/prismic#index'
  get '/types', to: 'prismic_document/prismic#types', as: :types
end