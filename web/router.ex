defmodule WebappExternalProcess.Router do
  use WebappExternalProcess.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebappExternalProcess do
    pipe_through :browser # Use the default browser stack

    get "/", NoteController, :index
    resources "/notes", NoteController
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebappExternalProcess do
  #   pipe_through :api
  # end
end
