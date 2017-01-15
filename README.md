# Überauth Gitlab
GitLab OAuth2 strategy for Überauth.

# Installation

1. Setup your [Gitlab application](http://docs.gitlab.com/ce/integration/oauth_provider.html)
2. Add `:ueberauth_gitlab` as a dependency in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_gitlab, "~> 0.1"}]
    end
    ```

3. Add the strategy to your application:

  ```elixir
  def application do
    [applications: [:ueberauth_gitab]]
  end
  ```

4. Add Gitlab to your Uberauth configuration:

  ```elixir
  config :ueberauth, Ueberauth,
    providers: [
      ...
      gitlab: {Ueberauth.Strategy.Gitlab, []}
    ]
  ```

5. Configure the provider with the application registration credentials, setting the actual values in environment variables:

  ```elixir
  config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
    client_id: System.get_env("GITLAB_CLIENT_ID"),
    client_secret: System.get_env("GITLAB_CLIENT_SECRET")
  ```

6. Make sure that the `/auth/:provider` and `/auth/:provider/callback` routes are properly configured, as explained in the [Ueberauth documentation](https://github.com/ueberauth/ueberauth/blob/master/README.md)

# Usage

Authentication is then available at your application's `/auth/gitlab` endpoint.
