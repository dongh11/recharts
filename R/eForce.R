#####################################
##  The network graph:
##		   Jobs(10)
##		  //1     \\2
##       //    3   \\
##    Gates(9)----Obama(8)
##
##  The weighted network Matrix would be:
##        Jobs   Gates  Obama
##  Jobs   0       1      2
##  Gates  1       0      3
##  Obama  2       3      0
##
##  The property data.frame:
##         category   value    color
##  Jobs   "人物"       10   '#ff7f50'
##  Gates  "朋友"       8    '#87cdfa'
##  Obama  "朋友"       9    '#87cdfa'
#######################################



# networkMatrix <- matrix(c(
# 	c(0, 1, 2, 1, 2, 3, 6, 6, 1, 1, 1 ),
# 	c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
#	c(2, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0 ),
#	c(1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0 ),
#	c(2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ),
#	c(3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ),
#	c(6, 0, 1, 1, 1, 1, 0, 6, 0, 1, 0 ),
#	c(6, 0, 0, 1, 0, 0, 6, 0, 0, 0, 0 ),
#	c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
#	c(1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ),
#	c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
#	), ncol=11
# )

# propertyDf <- data.frame(
#	category = c("人物", "家人", "家人", "家人", "家人", "朋友", 
#				"朋友", "朋友", "朋友", "朋友", "朋友"),
#	name = c("Steven Jobs", "Lisa Jobs", "Paul Jobs", " Kalala Jobs",
#			"Lauren Powell", "Steve woz Ike", "Obama", "Bill Gates", 
# 			"Jonathan", "Tim Cook", "Wayne"),
#	value = c(10, 2, 3, 3, 7, 5, 8, 9, 4, 4, 0)
#  )

# rownames(propertyDf) = propertyDf$name

# eForce(networkMatrix=networkMatrix, propertyDf=propertyDf, only=T)

## testData <- matrix(1:25, nrow=5)
## eForce(testData, only=T)
##

eForce = function(networkMatrix, propertyDf=NULL, opt=list(), only=FALSE, local=FALSE, style=NULL) {
	## networkMatrix would be a symmetric matrix (对称矩阵)
	## if the propertyDf is null, all the category and value are 0 as default.
	
		
    if(is.null(opt$legend$data)) {
        opt$legend$data = colnames(networkMatrix)
    }
	
	if(is.null(opt$tooltip)) {
		opt$tooltip$trigger = 'item'
		opt$tooltip$formatter = '{a} : {b}'
    }
	
	if(is.null(opt$title)) {
		opt$title$text = 'network Matrix Ouput'
		opt$title$subtext = ''
		opt$title$x = "right"
		opt$title$y = "bottom"
    }
	
	
	
	
	
	if(!is.null(propertyDf) && (nrow(propertyDf) != nrow(networkMatrix))){
		warning("dat matrix doesn't have the same length to propertyDf. The propertyDf will be ignored.")
		propertyDf = NULL
	}

	
	networkMatrix <- as.matrix(networkMatrix)
	if (nrow(networkMatrix) != ncol(networkMatrix))  stop("networkMatrix would be a symmetric matrix")
	
	# matrix name check.
	if (is.null(colnames(networkMatrix))){
		if (is.null(rownames(networkMatrix))){
			if (is.null(propertyDf)){
				# if the rowname, colname and the propertyDf are missing, will use 1:nrow as names.
				rownames(networkMatrix) = 1:nrow(networkMatrix)
				colnames(networkMatrix) = 1:nrow(networkMatrix)
			}else{
				# if the propertyDf is not Null, the matrix name will use the propertyDf names.
				rownames(networkMatrix) = rownames(propertyDf)
				colnames(networkMatrix) = rownames(propertyDf)
			}
		}else{
			colnames(networkMatrix) = rownames(networkMatrix)
		}
	}
	
	if(!is.null(rownames(propertyDf))) rownames(propertyDf) = rownames(networkMatrix)
	
	# transfer the network Matrix to links items.
	networkMatrix[!lower.tri(networkMatrix)] <- NA
	networkMatrix[networkMatrix==0] <- NA
	validNode <- as.data.frame(t(which(!is.na(networkMatrix), arr.ind=TRUE)))
	linksOutput <- lapply(validNode, FUN=function(nodeIndex){
		return(
			list(
				source = nodeIndex[1] - 1,
				target = nodeIndex[2] - 1,
				weight = networkMatrix[nodeIndex[1], nodeIndex[2]]
			)
		)
	})
	
	names(linksOutput) <- NULL
	
	# set the nodes property item.
	
	#set the default color array.
	.gg.color.hue <- function(n) {
		hues = seq(15, 375, length=n+1)
		hcl(h=hues, l=65, c=100)[1:n]
	}

	#If the propertyDf is null, will use category = 0, value=0 as default.
	if (is.null(propertyDf)){
		nodesOutput <- lapply(colnames(networkMatrix), FUN = function(nodeName){
			return(
				list(
					category = 0,
					name = nodeName,
					value = 0
				)
			)
		})
		
		categoriesOutput <- list(list(
			name = "默认类别",
			itemStyle = list(
				normal = list(
					color = .gg.color.hue(1)
				)
			)
		))
		
		
	}else{
		if(is.null(propertyDf$value)){
			# if the propertyDf has no column named value, the value will set to 0.
			propertyDf$value=0
		}
		if(is.null(propertyDf$color)){
			# if the propertyDf has no column named color, the color will be default to the .gg.color.hue class.
			# Also, the color will be .gg.color.hue(1) if the category column missed at the same time.
			if (is.null(propertyDf$category)){
				propertyDf$category = 0
				propertyDf$color = .gg.color.hue(1)
			}else{
				categoryList = unique(propertyDf$category)
				colArray = .gg.color.hue(length(categoryList))
				for(category in categoryList ){
					propertyDf[which(propertyDf$category == category), "color"] = colArray[which(categoryList == category)]
				}
			}
		}
		
		categoryList = unique(propertyDf$category)
		nodesOutput <- lapply(colnames(networkMatrix), FUN = function(nodeName){
			indexOfDf = which(rownames(propertyDf) == nodeName)[1]
			if(is.na (indexOfDf)){
				return(
					list(
						category = 0,
						name = nodeName,
						value = 0
					)
				)
			}else{
				return(
					list(
						category = which(categoryList == propertyDf[indexOfDf, "category"]) - 1,
						name = nodeName,
						value = propertyDf[indexOfDf, "value"]
					)
				)
			}
		})
		
		categoriesOutput <- lapply(categoryList, function(category){
			return(
					list(
						name = category,
						itemStyle = list(
							normal = list(
								color = propertyDf[which(propertyDf$category == category),  "color"][1]
							)
						)
					)
				)
			}
		)
	}

	if(is.null(opt$series$type)) {
		opt$series$type = "force"
	}
	
	if(is.null(opt$series$minRadius)) {
		opt$series$minRadius = 15
	}
		
	if(is.null(opt$series$maxRadius)) {
		opt$series$maxRadius = 25
	}

	if(is.null(opt$series$density)) {
		opt$series$density = 0.05
	}
		
	if(is.null(opt$series$attractiveness)) {
		opt$series$attractiveness = 1.2
	}
		
	if(is.null(opt$series$itemStyle)) {
		itemStyleOutput = list(
			normal = list(
				label = list(
					show = "true",
					textStyle = list(color="#800080")
				),
				nodeStyle = list(
					brushType = "both",
					strokeColor = "rgba(255,215,0,0.4)",
					lineWidth = 8
				)
			),
			emphasis = list(
				label = list(
					show = "true"
				),
				nodeStyle = list(
					r = 30
				)
			)
		)
	}
		
	
	opt$series$itemStyle = itemStyleOutput
	opt$series$categories = categoriesOutput
	opt$series$nodes = nodesOutput
	opt$series$links = linksOutput
	
		
	opt$series = list(opt$series)
	
	optJSON = RJSONIO::toJSON(opt)
	
	if(is.null(style)) {
        style = "height:500px;border:1px solid #ccc;padding:10px;"
    }	
		
	configHtml(opt=optJSON, only=only, local=local, style=style)
	
		
}		
		