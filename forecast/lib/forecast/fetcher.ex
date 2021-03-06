defmodule Forecast.Fetcher do

  import ExPrintf
  require Logger

  @user_agent [ { "User-agent", "Elixir test agent" } ]
  @yahoo_url        Application.get_env(:forecast, :yahoo_url)
  @yahoo_query      Application.get_env(:forecast, :yahoo_query)
  @yahoo_url_extra  Application.get_env(:forecast, :yahoo_url_extra)

  def fetch(location) do
    Logger.info "Fetching the data for location: #{location}"
    fetch_url(location)
      |> HTTPoison.get(@user_agent)
      |> handle_response
  end

  def fetch_url(location) do
    encoded_query = @yahoo_query
                      |> sprintf([location])
                      |> URI.encode_www_form
    "#{@yahoo_url}#{encoded_query}#{@yahoo_url_extra}"
  end

  def handle_response({ :ok, %HTTPoison.Response{ status_code: 200, body: body } }) do
    Logger.info "Successful response"
    Logger.debug "Response body: #{body}"
    { :ok, parsed_body, _ } = parse_response body
    { :ok, parsed_body }
  end

  def handle_response({ :ok, %HTTPoison.Response{ status_code: 404, body: _body } }) do
    Logger.error "The URL returned not found"
    { :error, "not found" }
  end

  def handle_response({ :error, %HTTPoison.Error{ reason: reason } }) do
    Logger.error "Error: #{reason}"
    { :error, reason }
  end

  def parse_response(body) do
    :erlsom.simple_form(body, [{ :nameFun, fn(name, _, _) -> name; end }])
  end

end

