defmodule OddishWeb.Router do
  use OddishWeb, :router

  import OddishWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OddishWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :assign_org_to_scope
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", OddishWeb do
  #   pipe_through [:browser, :require_authenticated_user]

  #   get "/", PageController, :home

  # end

  scope "/o/:org/", OddishWeb do
    pipe_through :browser

    live_session :app,
      on_mount: [
        {OddishWeb.UserAuth, :mount_current_scope},
        {OddishWeb.UserAuth, :assign_org_to_scope}
      ] do
      live "/", HomeLive.Home, :index

      live "/soltas", SoltaLive.Index, :index
      live "/soltas/new", SoltaLive.Form, :new
      live "/soltas/:id", SoltaLive.Show, :show
      live "/soltas/:id/edit", SoltaLive.Form, :edit

      live "/grazes", GrazeLive.Index, :history
      live "/grazes/new", GrazeLive.Form, :new
      live "/grazes/history", GrazeLive.History, :index
      live "/grazes/:id", GrazeLive.Show, :show
      live "/grazes/:id/edit", GrazeLive.Form, :edit

      live "/bovines", BovineLive.Index, :index
      live "/bovines/new", BovineLive.Form, :new
      live "/bovines/:id", BovineLive.Show, :show
      live "/bovines/:id/edit", BovineLive.Form, :edit

      live "/packs", PackLive.Index, :index
      live "/packs/new", PackLive.Form, :new
      live "/packs/:id", PackLive.Show, :show
      live "/packs/:id/edit", PackLive.Form, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OddishWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:oddish, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OddishWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", OddishWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{OddishWeb.UserAuth, :require_authenticated}] do
      live "/", OrganizationLive.Index, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", OddishWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{OddishWeb.UserAuth, :mount_current_scope}] do
      # live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
