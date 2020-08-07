defmodule KvStoreWeb.Router do
  use KvStoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KvStoreWeb do
    pipe_through :api

    get "/get", StoreController, :get
    get "/get/:id", StoreController, :get
    post "/put", StoreController, :put
  end
end
