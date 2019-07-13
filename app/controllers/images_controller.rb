class ImagesController < ApplicationController
  
  require 'securerandom'
  require 'net/http'
  require 'uri'

  def index
  end

  def create

    # サブミットされた画像ファイルを取得
    uploaded_file = image_params[:file]

    # 画像ファイルを適当に保存する
    output_path = Rails.root.join('public', SecureRandom.hex(8))
    File.open(output_path, 'w+b') do |fp|
     fp.write  uploaded_file.read
    end
    
    # 画像ファイルをRMagickに変換
    img = Magick::ImageList.new(output_path)
    img = img.quantize(256, Magick::RGBColorspace)
    
    # 出力用の２次元配列を作成
    array = Array.new(28) { Array.new(28,0) }

    # pngファイルは16ビットのカラー画像として読み込まれるので、８ビットのグレースケールに変換
    for y in 0...img.rows
      for x in 0...img.columns
        src = img.pixel_color(x, y) # 元画像のピクセルを取得
        array[x][y] = (src.red + src.green + src.blue)/3/256
      end
    end

    #tensorflow servingのjsonフォーマットを作成
    data = '{"signature_name": "serving_default", "inputs": ['
    data += array.to_s
    data += ']}'

    # httpのpostリクエストを発行
    uri = URI.parse("http://localhost:8501/v1/models/fmnist_model:predict")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = data

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # 結果をjson形式に変換し取り出す
    result_json = JSON.parse(response.body)
    result_list = result_json["outputs"][0]
    max_index = result_list.index(result_list.max)

    # 最大の値となるインデックスをラベルに変換し、clientに返す
    render :json => view_context.get_label(max_index)

  end

  private
  def image_params
    params.require(:image).permit(:file)
  end

end
