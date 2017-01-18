defmodule Ueberauth.Strategy.Gitlab.OAuth do
    @moduledoc """
    An implementation of OAuth2 for gitlab.

    To add your `client_id` and `client_secret` include these values in your configuration.
        config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
        client_id: System.get_env("GITLAB_CLIENT_ID"),
        client_secret: System.get_env("GITLAB_CLIENT_SECRET")
    """
    use OAuth2.Strategy

    @defaults [
        strategy: __MODULE__,
        site: "https://gitlab.com",
        authorize_url: "https://gitlab.com/oauth/authorize",
        token_url: "https://gitlab.com/oauth/token"
    ]

    @doc """
    Construct a client for requests to Gitlab.
    
    Optionally include any OAuth2 options here to be merged with the defaults. For instance,
    if you wish to use your own Gitlab server:
    
        Ueberauth.Strategy.Gitlab.OAuth.client(site: "https://gitlab.example.com/",
                        authorize_url: "https://gitlab.example.com/oauth/authorize",
                        token_url: "https://gitlab.example.com/oauth/token")
        
    This will be setup automatically for you in `Ueberauth.Strategy.Gitlab`.
    These options are only useful for usage outside the normal callback phase of Ueberauth.
    """
    def client(opts \\ []) do
        config = Application.get_env(:ueberauth, Ueberauth.Strategy.Gitlab.OAuth)
        client_ops = @defaults |> Keyword.merge(config) |> Keyword.merge(opts)
        OAuth2.Client.new(client_ops)
    end
    
    def authorize_url!(params \\ [], opts \\ []) do
        opts |> client |> OAuth2.Client.authorize_url!(params)
    end

    def get(token, url, headers \\ [], opts \\ []) do
        client
        |> put_param("client_secret", client().client_secret)
        |> put_header("Authorization", "#{token.token_type} #{token.access_token}")
        |> OAuth2.Client.get(url, headers, opts)
    end

    def get_token!(params \\ [], options \\ []) do
        headers = Keyword.get(options, :headers, [])
        options = Keyword.get(options, :options, [])
        client_options = Keyword.get(options, :client_options, [])
        client = OAuth2.Client.get_token!(client(client_options), params, headers, options)
        client.token
    end

    def authorize_url(client, params) do
        OAuth2.Strategy.AuthCode.authorize_url(client, params)
    end

    def get_token(client, params, headers) do
        client
        |> put_param("client_secret", client.client_secret)
        |> put_header("Accept", "application/json")
        |> OAuth2.Strategy.AuthCode.get_token(params, headers)
    end
end