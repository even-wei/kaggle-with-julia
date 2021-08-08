### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 3909a581-7d5d-49da-a7b6-7d574a9a8e67
begin
	using CSV
	using DataFrames
	using MLDataUtils
end

# ╔═╡ 973690c7-001f-4110-b1be-5066123f067d
begin
	using ScikitLearn
	using DecisionTree
	using Statistics
end

# ╔═╡ 7bc884cc-f825-11eb-05ac-9d97ec1c19b5
md"# Housing Prices Competition for Kaggle Learn Users"

# ╔═╡ 8fc7b9a9-5edb-445f-acfc-efbf80289567
md"## Download datasets"

# ╔═╡ f0bb2843-6351-46e6-a9af-6001a2c01bec
md"Please make sure `kaggle` command is installed. [kaggle-api github](https://github.com/Kaggle/kaggle-api)"

# ╔═╡ dfa20ffd-442d-4fe9-915f-76f176f9ee3a
begin
	run(`kaggle competitions download -c home-data-for-ml-course -f train.csv`)
	run(`kaggle competitions download -c home-data-for-ml-course -f test.csv`)
end

# ╔═╡ 88ed2deb-b2b8-41fc-adc7-0b79fb345bf6
md"## Prepare Datasets"

# ╔═╡ 1ad6c7fa-a9f6-4886-8424-64bc7c44117c
md"### Import Modules"

# ╔═╡ edb88725-c559-4dc9-b8b1-e45e728800a3
md"### Load Training Dataset"

# ╔═╡ 34ba5692-1a67-4fe8-9727-af2df3a0e776
begin
	home_data = CSV.File("train.csv") |> DataFrame
	train_home_data, val_home_data = splitobs(home_data, at = 0.9)
end

# ╔═╡ 029acc00-ca97-4c77-b954-7f818988ac65
md"### Select Features"

# ╔═╡ ea1795ae-946e-4579-b684-9608d7734c3c
features = [
	"LotArea",
	"YearBuilt",
	"1stFlrSF",
	"2ndFlrSF",
	"FullBath",
	"BedroomAbvGr",
	"TotRmsAbvGrd"
]

# ╔═╡ b910f0d5-afa2-464a-bd9b-33ec9aee5c20
md"### Training and Validation Datasets"

# ╔═╡ eb9d7236-785b-40ed-ae42-97f9a65814ee
begin
	X = home_data[!, features]
	y = home_data.SalePrice
	train_X = train_home_data[!, features]
	train_y = train_home_data.SalePrice
	val_X = val_home_data[!, features]
	val_y = val_home_data.SalePrice
end

# ╔═╡ 0280809c-fe3c-4f4f-b88e-f6ebae7d4008
md"### Testing Datasets"

# ╔═╡ 11bfdd61-a0ae-4018-9dfc-65135c72b286
begin
	test_home_data = CSV.File("test.csv") |> DataFrame
	test_X = test_home_data[!, features]
end

# ╔═╡ c3e2c05f-fe5d-41e3-bd77-ae67b055c6f1
md"## Train Models"

# ╔═╡ f69630ee-d18d-4cce-a7ed-2b8dc5decd3f
md"### Import Modules"

# ╔═╡ 290266cc-4aa5-4fc0-8b5c-8a7f5ad9b6e8
md"### Mean Absolute Error"

# ╔═╡ 4d8eea32-5062-425b-bd4c-0d78f1a9a7f5
function get_mae(val, pred)
	return mean(abs(sum(val .- pred)))
end

# ╔═╡ 0df54ead-3090-44c2-9612-514f88500264
md"### Decision Tree Regressor"

# ╔═╡ 09251e92-1ced-497c-8aa2-9c18c90ac688
begin
	dtr_model = DecisionTreeRegressor(rng=1)
	fit!(dtr_model, Matrix(train_X), train_y)
	dtr_pred_y = ScikitLearn.predict(dtr_model, Matrix(val_X))
	dtr_mae = get_mae(val_y, dtr_pred_y)
end

# ╔═╡ c7ec23d9-354c-44c1-a24e-e3b06f77bd26
begin
	full_dtr_model = DecisionTreeRegressor(rng=1)
	fit!(full_dtr_model, Matrix(X), y)
	dtr_result = ScikitLearn.predict(full_dtr_model, Matrix(test_X))
end

# ╔═╡ a11012ea-469e-4140-8e53-fc06d24e6fcb
begin
	dtr_df = DataFrame(
		Id = test_home_data.Id,
		SalePrice = dtr_result
	)
	CSV.write("dtr_result.csv", dtr_df)
end

# ╔═╡ 27932df1-5f3a-4ec7-bb99-3a3e8f94b582
md"### Random Forest Regressor"

# ╔═╡ 2d1f6590-cb93-4773-9e01-54cbbfece0c9
begin
	rfr_model = RandomForestRegressor(rng=1)
	fit!(rfr_model, Matrix(train_X), train_y)
	rfr_pred_y = ScikitLearn.predict(rfr_model, Matrix(val_X))
	rfr_mae = get_mae(val_y, rfr_pred_y)
end

# ╔═╡ 0106bd03-e5a8-40ab-8cf9-a995a011ad69
begin
	full_rfr_model = RandomForestRegressor(rng=1)
	fit!(full_rfr_model, Matrix(X), y)
	rfr_result = ScikitLearn.predict(full_rfr_model, Matrix(test_X))
end

# ╔═╡ ceda4142-51a5-4bfa-a26e-b619ec6c3754
begin
	rfr_df = DataFrame(
		Id = test_home_data.Id,
		SalePrice = rfr_result
	)
	CSV.write("rfr_result.csv", rfr_df)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DecisionTree = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
MLDataUtils = "cc2ba9b6-d476-5e6d-8eaf-a92d5412d41d"
ScikitLearn = "3646fa90-6ef7-5e7e-9f22-8aca16db6324"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
DecisionTree = "~0.10.10"
MLDataUtils = "~0.5.4"
ScikitLearn = "~0.6.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[Conda]]
deps = ["JSON", "VersionParsing"]
git-tree-sha1 = "299304989a5e6473d985212c28928899c74e9421"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.5.2"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DecisionTree]]
deps = ["DelimitedFiles", "Distributed", "LinearAlgebra", "Random", "ScikitLearnBase", "Statistics", "Test"]
git-tree-sha1 = "8b58db7954a6206399d9f66ef1a328da8c0f1d19"
uuid = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
version = "0.10.10"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LearnBase]]
deps = ["LinearAlgebra", "StatsBase"]
git-tree-sha1 = "47e6f4623c1db88570c7a7fa66c6528b92ba4725"
uuid = "7f8f8fb0-2700-5f03-b4bd-41f8cfc144b6"
version = "0.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MLDataPattern]]
deps = ["LearnBase", "MLLabelUtils", "Random", "SparseArrays", "StatsBase"]
git-tree-sha1 = "e99514e96e8b8129bb333c69e063a56ab6402b5b"
uuid = "9920b226-0b2a-5f5f-9153-9aa70a013f8b"
version = "0.5.4"

[[MLDataUtils]]
deps = ["DataFrames", "DelimitedFiles", "LearnBase", "MLDataPattern", "MLLabelUtils", "Statistics", "StatsBase"]
git-tree-sha1 = "ee54803aea12b9c8ee972e78ece11ac6023715e6"
uuid = "cc2ba9b6-d476-5e6d-8eaf-a92d5412d41d"
version = "0.5.4"

[[MLLabelUtils]]
deps = ["LearnBase", "MappedArrays", "StatsBase"]
git-tree-sha1 = "3211c1fdd1efaefa692c8cf60e021fb007b76a08"
uuid = "66a33bbf-0c2b-5fc8-a008-9da813334f0a"
version = "0.5.6"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "169bb8ea6b1b143c5cf57df6d34d022a7b60c6db"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.92.3"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[ScikitLearn]]
deps = ["Compat", "Conda", "DataFrames", "Distributed", "IterTools", "LinearAlgebra", "MacroTools", "Parameters", "Printf", "PyCall", "Random", "ScikitLearnBase", "SparseArrays", "StatsBase", "VersionParsing"]
git-tree-sha1 = "ccb822ff4222fcf6ff43bbdbd7b80332690f168e"
uuid = "3646fa90-6ef7-5e7e-9f22-8aca16db6324"
version = "0.6.4"

[[ScikitLearnBase]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "7877e55c1523a4b336b433da39c8e8c08d2f221f"
uuid = "6e75b9c4-186b-50bd-896f-2d2496a4843e"
version = "0.5.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "a3a337914a035b2d59c9cbe7f1a38aaba1265b02"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.6"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[VersionParsing]]
git-tree-sha1 = "80229be1f670524750d905f8fc8148e5a8c4537f"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.0"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─7bc884cc-f825-11eb-05ac-9d97ec1c19b5
# ╟─8fc7b9a9-5edb-445f-acfc-efbf80289567
# ╟─f0bb2843-6351-46e6-a9af-6001a2c01bec
# ╠═dfa20ffd-442d-4fe9-915f-76f176f9ee3a
# ╟─88ed2deb-b2b8-41fc-adc7-0b79fb345bf6
# ╟─1ad6c7fa-a9f6-4886-8424-64bc7c44117c
# ╠═3909a581-7d5d-49da-a7b6-7d574a9a8e67
# ╟─edb88725-c559-4dc9-b8b1-e45e728800a3
# ╠═34ba5692-1a67-4fe8-9727-af2df3a0e776
# ╟─029acc00-ca97-4c77-b954-7f818988ac65
# ╠═ea1795ae-946e-4579-b684-9608d7734c3c
# ╟─b910f0d5-afa2-464a-bd9b-33ec9aee5c20
# ╠═eb9d7236-785b-40ed-ae42-97f9a65814ee
# ╟─0280809c-fe3c-4f4f-b88e-f6ebae7d4008
# ╠═11bfdd61-a0ae-4018-9dfc-65135c72b286
# ╟─c3e2c05f-fe5d-41e3-bd77-ae67b055c6f1
# ╟─f69630ee-d18d-4cce-a7ed-2b8dc5decd3f
# ╠═973690c7-001f-4110-b1be-5066123f067d
# ╟─290266cc-4aa5-4fc0-8b5c-8a7f5ad9b6e8
# ╠═4d8eea32-5062-425b-bd4c-0d78f1a9a7f5
# ╟─0df54ead-3090-44c2-9612-514f88500264
# ╠═09251e92-1ced-497c-8aa2-9c18c90ac688
# ╠═c7ec23d9-354c-44c1-a24e-e3b06f77bd26
# ╠═a11012ea-469e-4140-8e53-fc06d24e6fcb
# ╟─27932df1-5f3a-4ec7-bb99-3a3e8f94b582
# ╠═2d1f6590-cb93-4773-9e01-54cbbfece0c9
# ╠═0106bd03-e5a8-40ab-8cf9-a995a011ad69
# ╠═ceda4142-51a5-4bfa-a26e-b619ec6c3754
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
