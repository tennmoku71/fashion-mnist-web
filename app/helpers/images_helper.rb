module ImagesHelper
	def get_label(index)
		label_hash = {
			
			0 => "T-shirt/top",
			1 => "Trouser",
			2 => "Pullover",
			3 =>	"Dress",
			4 =>	"Coat",
			5 =>	"Sandal",
			6 =>	"Shirt",
			7 =>	"Sneaker",
			8 =>	"Bag",
			9 =>	"Ankle boot"
		}

		return label_hash[index]
	end
end
