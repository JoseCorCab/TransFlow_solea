#! /usr/bin/env ruby
pca_path = ARGV[0]

data = {}
dim = nil
state = nil
dim_data = nil
File.open(pca_path).each do |line|
	line.chomp!
	if line.include?('#')
		next
	elsif line.include?('null device')
		break
	elsif line.include?('average_distances')
		dim='r'
		state='Distances'
		dim_data = { 'Distances' => [] }
	elsif line.include?('clust')
		data[dim] = dim_data if !dim.nil?
		dim='c'
		state = 'Cluster'
		dim_data = { 'Cluster' => [] }
	elsif line =~ /\$Dim\.(\d)$/
		if !dim_data.nil?
			data[dim] = dim_data
		end
		dim = $1
		dim_data = {}
	elsif line =~ /\$Dim\.\d\$quanti/
		state = 'DimQuanti'
		dim_data['Variables'] = []
	elsif line =~ /\$Dim\.\d\$quali/
                state = 'DimQuali'
                dim_data['Factors'] = []
        elsif line =~ /\$Dim\.\d\$category/
                state = 'DimCat'
                dim_data['Categories'] = []
	elsif line == '' || 
		(line.include?('correlation') && line.include?('p.value')) || 
		(line.include?('R2') && line.include?('p.value')) || 
		(line.include?('Estimate') && line.include?('p.value'))
		next
	elsif state == 'Distances'
		dim_data['Distances'] << line.split(' ')
	elsif state == 'Cluster'
		dim_data['Cluster'] << line.split(' ')
	elsif state == 'DimQuanti'
		dim_data['Variables'] << line.split(' ')
	elsif state == 'DimQuali'
		dim_data['Factors'] << line.split(' ')
	elsif state == 'DimCat'
		dim_data['Categories'] << line.split(' ')
	end
end
data[dim] = dim_data
data.each do |dim, dim_data|
	if dim == 'r'
		puts "#{dim}\tPCA Ranking\tcolspan"
	elsif dim == 'c'
		puts "#{dim}\tCluster data\tcolspan\tcolspan\tcolspan\tcolspan"
		clusters = dim_data['Cluster'].map{|row| row.last}.sort.uniq
		sorted_clusters = []
		clusters.each do |id|
			cluster = dim_data['Cluster'].select{|row| row.last == id}
			cluster.sort!{|r1, r2| r1.first <=> r2.first}
			sorted_clusters.concat(cluster)
		end
		dim_data['Cluster'] = sorted_clusters
	else
		puts "#{dim}\tPCA dimension #{dim}\tcolspan\tcolspan"
	end
	dim_data.each do |type, significant_data|
		if dim == 'r'
			puts "#{dim}\t<center><b>Name</b></center>\t<center><b>PCA distance</b></center>"
		elsif dim == 'c'
			puts "#{dim}\t<center><b>Name</b></center>\t<center><b>Coord Dim1</b></center>\t<center><b>Coord Dim2</b></center>\t<center><b>Coord Dim3</b></center>\t<center><b>Cluster</b></center>"
		else
			puts "#{dim}\t<center><b>#{type}</b></center>\tcolspan\tcolspan"
		end
		puts "#{dim}\t<i>Name</i>\t<i>Correlation coef</i>\t<i>p-valor</i>" if type == 'Variables'
		puts "#{dim}\t<i>Name</i>\t<i>R2</i>\t<i>p-valor</i>" if type == 'Factors'
		puts "#{dim}\t<i>Name</i>\t<i>Estimate</i>\t<i>p-valor</i>" if type == 'Categories'
		significant_data.each do |dat|
			puts [dim].concat(dat).join("\t")
		end
	end
end

