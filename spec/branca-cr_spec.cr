require "./spec_helper"


macro encoding_test(no, payload)
  it "vector_test.json - encoding test No.{{no}}" do
    data = json["testGroups"][0]["tests"][{{no}}]

    config = TestConfiguration.new key: data["key"].as_s.to_slice
    config.nonce = data["nonce"].as_s.hexbytes

    branca = Branca::Token.new
    branca.timestamp = data["timestamp"].as_i64.to_u64
    token = branca.encode {{payload}}, config

    token.should eq data["token"].as_s
  end
end

# TODO: "hello world" が表示されるテスト、バイナリの照合を必要とするテスト、失敗することを想定するデストの場合によってmacroを作る

macro decoding_success_test(no, body)
  it "vector_test.json - decoding test No.{{no}}" do
    data = json["testGroups"][1]["tests"][{{no - 8}}]

    config = Branca::Configuration.new key: data["key"].as_s.to_slice
    branca = Branca::Token.new
    branca.decode(data["token"].as_s, config).should eq({{body}})
    branca.timestamp.should eq data["timestamp"].as_i64.to_u64
  end
end

macro decoding_failure_test(no, exception)
  it "vector_test.json - decoding test No.{{no}}" do
    data = json["testGroups"][1]["tests"][{{no - 8}}]

    expect_raises({{exception}}) do
      config = Branca::Configuration.new key: data["key"].as_s.to_slice
      branca = Branca::Token.new
      branca.decode data["token"].as_s, config
    end
  end
end

describe Branca::Token do
  describe "#encode" do
    json = JSON.parse File.open "./spec/test_vectors.json"
    encoding_test 0, "Hello world!".to_slice
    encoding_test 1, "Hello world!".to_slice
    encoding_test 2, "Hello world!".to_slice
    encoding_test 3, Bytes.new(8, 0)
    encoding_test 4, Bytes.new(8, 0)
    encoding_test 5, Bytes.new(8, 0)
    encoding_test 6, Bytes.empty
    encoding_test 7, Bytes.new(1, 0x80.to_u8)
  end

  describe "#decode" do
    json = JSON.parse File.open "./spec/test_vectors.json"
    decoding_success_test 8, "Hello world!".to_slice
    decoding_success_test 9, "Hello world!".to_slice
    decoding_success_test 10, "Hello world!".to_slice
    decoding_success_test 11, Bytes.new(8, 0)
    decoding_success_test 12, Bytes.new(8, 0)
    decoding_success_test 13, Bytes.new(8, 0)
    decoding_success_test 14, Bytes.empty
    decoding_success_test 15, Bytes.new(1, 0x80.to_u8)
    decoding_failure_test 16, Branca::Error::InvaildVersion
    decoding_failure_test 17, Branca::Error::Base62UnexpectedChar
    decoding_failure_test 18, Branca::Error::InvaildVersion
    decoding_failure_test 19, Branca::Error::InvaildToken
    decoding_failure_test 20, Branca::Error::InvaildToken
    decoding_failure_test 21, Branca::Error::InvaildToken
    decoding_failure_test 22, Branca::Error::InvaildToken
    decoding_failure_test 23, Branca::Error::InvaildToken
    decoding_failure_test 24, Branca::Error::InvaildKeySize
  end
end
