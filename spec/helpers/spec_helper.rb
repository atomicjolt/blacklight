require "webmock/minitest"
WebMock.disable_net_connect!(allow_localhost: true)

def fixture_finder(name)
  File.join(File.dirname(__FILE__), "..", "fixtures", name)
end

def stub_toe(type, pattern, json, with_params = nil)
  request = stub_request(type, pattern).
    to_return(
      status: 200,
      body: json,
      headers: { content_type: "json" },
    )
  if with_params
    request.with(with_params)
  end
end

def stub_active_courses_in_account(json)
  stub_toe(:get, /v1\/accounts\/self\/courses/, json)
end
