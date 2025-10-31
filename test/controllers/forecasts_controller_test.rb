require "test_helper"

class ForecastsControllerTest < ActionController::TestCase
  describe "GET #new" do
    it "should render the new template successfully" do
      get :new
      assert_response :success
    end
  end

  describe "POST #create" do
    it "should redirect to forecast show path with encoded address" do
      post :create, params: { address: "Hyderabad" }
      assert_response :redirect
      expected_path = forecast_path(Base64.urlsafe_encode64("Hyderabad"))
      assert_equal expected_path, URI(response.location).path
    end

    it "should handle missing or blank address param gracefully" do
      post :create, params: { address: nil }
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  describe "GET #show" do
    it "should redirect to root if address is invalid" do
      get :show, params: { id: "invalid_base64" }
      assert_redirected_to root_path
      assert_equal "Invalid address", flash[:alert]
    end

    it "should redirect if location not found" do
      encoded = Base64.urlsafe_encode64("UnknownLand")
      Geocoder.stub :search, [] do
        get :show, params: { id: encoded }
        assert_redirected_to root_path
        assert_equal "Unable to find location for 'UnknownLand'", flash[:alert]
      end
    end

    it "should return cached forecast if available" do
      zip = "500001"
      cache_key = "forecast_#{zip}"
      cached_data = { "weather" => [{ "description" => "Sunny" }] }
      Rails.cache.write(cache_key, cached_data)

      fake_location = OpenStruct.new(coordinates: [17.385, 78.4867])
      postal_stub = OpenStruct.new(postal_code: zip)

      Geocoder.stub(:search, [fake_location, postal_stub]) do
        get :show, params: { id: Base64.urlsafe_encode64("Hyderabad") }

        forecast = controller.instance_variable_get(:@forecast)
        cached = controller.instance_variable_get(:@cached)

        assert_equal cached_data, forecast
        assert_equal true, cached
        assert_response :success
      end
    end

    it "should fetch forecast from API if cache not found" do
      Rails.cache.clear
      encoded = Base64.urlsafe_encode64("Hyderabad")

      fake_location = OpenStruct.new(coordinates: [17.385, 78.4867])
      postal_stub = OpenStruct.new(postal_code: "500001")

      fake_response = Minitest::Mock.new
      fake_response.expect :success?, true
      fake_response.expect :parsed_response, { "main" => { "temp" => 28 } }

      Geocoder.stub(:search, [fake_location, postal_stub]) do
        HTTParty.stub :get, fake_response do
          get :show, params: { id: encoded }

          forecast = controller.instance_variable_get(:@forecast)
          cached = controller.instance_variable_get(:@cached)

          assert_equal({ "main" => { "temp" => 28 } }, forecast)
          assert_equal false, cached
          fake_response.verify
          assert_response :success
        end
      end
    end

    it "should redirect if API call fails" do
      encoded = Base64.urlsafe_encode64("Hyderabad")
      fake_location = OpenStruct.new(coordinates: [17.385, 78.4867])
      postal_stub = OpenStruct.new(postal_code: "500001")

      fake_response = Minitest::Mock.new
      fake_response.expect :success?, false

      Geocoder.stub(:search, [fake_location, postal_stub]) do
        HTTParty.stub :get, fake_response do
          get :show, params: { id: encoded }
          assert_redirected_to root_path
          assert_equal "Unable to fetch weather data", flash[:alert]
        end
      end
    end
  end
end
