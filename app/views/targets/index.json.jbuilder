json.array!(@targets) do |target|
  json.extract! target, :id, :description
  json.url target_url(target, format: :json)
end
