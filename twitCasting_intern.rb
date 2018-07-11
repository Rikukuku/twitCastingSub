require 'net/https'
require 'uri'
require 'json'

DIGIT_NUMBER = 3

droplet_ep = 'https://apiv2.twitcasting.tv/internships/2018/games?level=3'

token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjQ4MTM5ZGY4OWZkMTljNmU0M2JkNjc1ZDU4MmQxMWY5NTllMTU5ZDNlZDA2MWVjZmY4ODYwZDgxZjY1OTk1NTg3OWNjYmExOGQwYTFiOTU3In0.eyJhdWQiOiIxODIyMjQ5MzguZWVkZTdmMTk1N2FhYTA2ZDQwMzY1NjE1NjMxOTMyMzZkNDU3NWQ3YzA5MDM2NTUwOGZjZTE5NzU2YzI0ZDAzOSIsImp0aSI6IjQ4MTM5ZGY4OWZkMTljNmU0M2JkNjc1ZDU4MmQxMWY5NTllMTU5ZDNlZDA2MWVjZmY4ODYwZDgxZjY1OTk1NTg3OWNjYmExOGQwYTFiOTU3IiwiaWF0IjoxNTMwODgwNzc3LCJuYmYiOjE1MzA4ODA3NzcsImV4cCI6MTU0NjQzMjc3Nywic3ViIjoiZjoxODM2Mjc3MTIwMDIyNjg5Iiwic2NvcGVzIjpbInJlYWQiXX0.Tns-TpGGf7sSWF-prKpEnHgbJLHVFbAOBz4HwtFxr8WsZGcXdSGClVI0pTObQAHPue6GAPp3x9fWAcaoAnjvrL-m78b7LuyCgKTKiYhkAacLbn_sL0_NkpXom4tSZSyZS2qx1_RocJdgZbSAgcrWvwvYb_xzDRijrtBqKgb89dlmSnt66s8JCZV0m4VIP7VUOxLQXa7VY8PVgxXJrg5W9HPwxnAKZLWmFwdR7N7rUb773Zbep-EO453jhei5RbddglEtnmMqgWEX-FXFTSVCIJFuxiVjA2x1tUNnfoF01vAByu0e9iE8oa6fz-uW11NQqrCvecbPUwej1A4_YbMF8w'

def make_answer_number
  # 正解の数が生成できたか調べるフラグ
  answer_number_flag = false

  # 各桁の数が異なる数が生成されるまで無限ループ
  while !answer_number_flag
    # フラグは最初はtrue
    answer_number_flag = true

    # 正解の数を生成
    # 正解の数は10^(n-1)〜(10^n)-1の数
    rand_number = rand((10**(DIGIT_NUMBER - 1))..((10**DIGIT_NUMBER) - 1))

    # return用の変数
    return_answer_number = rand_number

    # 各桁の数を格納する配列
    rand_number_array = []

    # 各桁の数を配列に格納
    DIGIT_NUMBER.times do
      rand_number_array.push(rand_number % 10)
      rand_number /= 10
    end

    # 各桁の数が異なっていることを調べる
    rand_number_array.each_with_index do |digit_number, index|
      (index + 1).upto(rand_number_array.length - 1) do |upto_times|
        if digit_number == rand_number_array[upto_times]
          answer_number_flag = false
        end
      end
    end
  end

  return_answer_number
end

#================================================================
# =>                 ここからリクエストスタート
#================================================================

uri = URI.parse(droplet_ep)
http = Net::HTTP.new(uri.host, uri.port)

http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Get.new(uri.request_uri)
req["Authorization"] = "Bearer #{token}"

res = http.request(req)
puts res.code, res.msg
puts res.body

puts next_id = res.body.slice(7..38)


answer_flag = false
URL = "https://apiv2.twitcasting.tv/internships/2018/games/#{next_id}"
uri2 = URI.parse(URL)
https = Net::HTTP.new(uri2.host, uri2.port)

https.use_ssl = true
  while !answer_flag

    req2 = Net::HTTP::Post.new(uri2.request_uri)
    req2["Authorization"] = "Bearer #{token}"
    req2["Content-Type"] = "application/json"
    answer = make_answer_number
    payload = {
         "answer" => "#{answer}"
    }.to_json
    req2.body = payload # リクエストボデーにJSONをセット
    res2 = https.request(req2)

    # 返却の中身を確認する
    puts "code -> #{res2.code}"
    puts "msg -> #{res2.message}"
    puts "body -> #{res2.body}"
    p res2.code
    if res2.code != "200"
      answer_flag = true
    end
end
