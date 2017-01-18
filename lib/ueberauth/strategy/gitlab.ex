defmodule Ueberauth.Strategy.Gitlab do
    use Ueberauth.Strategy, uid_field: :username,
            default_scope: "read_user",
            oauth2_module: Ueberauth.Strategy.Gitlab.OAuth

    @gitlab_api_version "v3"
    @gitlab_user_endpoint "/api/#{@gitlab_api_version}/user"

    alias Ueberauth.Auth.Info
    alias Ueberauth.Auth.Credentials
    alias Ueberauth.Auth.Extra

    def handle_request!(conn) do
        scopes = conn.params["scope"] || option(conn, :default_scope)
        opts = [redirect_uri: callback_url(conn), scope: scopes]
        # TODO add state
        module = option(conn, :oauth2_module)
        redirect!(conn, apply(module, :authorize_url!, [opts]))
    end

    def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
        module = option(conn, :oauth2_module)
        token = apply(module, :get_token!, [[code: code, redirect_uri: callback_url(conn)]])

        if is_nil(token.access_token) do
            set_errors!(conn, [error(token.other_params["error"], token.other_params["error_description"])])
        else
            fetch_user(conn, token)
        end
    end

    def handle_callback!(conn) do
        set_errors!(conn, [error("missing_code", "No code received")])
    end

    def handle_cleanup!(conn) do
        conn
        |> put_private(:gitlab_user, nil)
        |> put_private(:gitlab_token, nil)
    end

    def uid(conn) do
        user = conn |> option(:uid_field) |> to_string
        conn.private.gitlab_user[user]
    end

    def credentials(conn) do
        token = conn.private.gitlab_token
        scope_string = (token.other_params["scope"] || "")
        scopes = String.split(scope_string, ",")

        %Credentials {
            token: token.access_token,
            refresh_token: token.refresh_token,
            expires_at: token.expires_at,
            token_type: token.token_type,
            expires: !!token.expires_at,
            scopes: scopes
        }
    end

    def info(conn) do
        user = conn.private.gitlab_user

        %Info {
            name: user["name"],
            email: user["email"] || Enum.find(user["emails"] || [], &(&1["primary"]))["email"],
            nickname: user["login"],
            location: user["location"],
            urls: %{
                avatar_url: user["avatar_url"],
                web_url: user["web_url"],
                website_url: user["website_url"]
            }
        }
    end

    def extra(conn) do
        %Extra {
            raw_info: %{
                token: conn.private.gitlab_token,
                user: conn.private.gitlab_user
            }
        }
    end

    defp fetch_user(conn, token) do
        conn = put_private(conn, :gitlab_token, token)
        case Ueberauth.Strategy.Gitlab.OAuth.get(token, @gitlab_user_endpoint) do
            {:ok, %OAuth2.Response{status_code: status_code_user, body: user}} when status_code_user in 200..399 ->
                put_private(conn, :gitlab_user, user)
            {:ok, %OAuth2.Response{status_code: 401, body: body}} ->
                set_errors!(conn, [error("token", "unauthorized: #{inspect body}")])
            {:error, %OAuth2.Error{reason: reason}} ->
                set_errors!(conn, [error("OAuth2", reason)])
            _ ->
                set_errors!(conn, [error("OAuth2", "An error occured")])
        end
    end
    
    defp option(conn, key) do
       Keyword.get(options(conn), key, Keyword.get(default_options(), key))
    end
end