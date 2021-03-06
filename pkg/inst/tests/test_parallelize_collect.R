context("parallelize() and collect()")

# Mock data
numVector <- c(-10:97)
numList <- list(sqrt(1), sqrt(2), sqrt(3), 4 ** 10)
strVector <- c("Dexter Morgan: I suppose I should be upset, even feel",
               "violated, but I'm not. No, in fact, I think this is a friendly",
               "message, like \"Hey, wanna play?\" and yes, I want to play. ",
               "I really, really do.")
strList <- list("Dexter Morgan: Blood. Sometimes it sets my teeth on edge, ",
                "other times it helps me control the chaos.",
                "Dexter Morgan: Harry and Dorris Morgan did a wonderful job ",
                "raising me. But they're both dead now. I didn't kill them. Honest.")

numPairs <- list(list(1, 1), list(1, 2), list(2, 2), list(2, 3))
strPairs <- list(list(strList, strList), list(strList, strList))

# JavaSparkContext handle
jsc <- sparkR.init()

# Tests

test_that("parallelize() on simple vectors and lists returns an RDD", {
  numVectorRDD <- parallelize(jsc, numVector, 1)
  numVectorRDD2 <- parallelize(jsc, numVector, 10)
  numListRDD <- parallelize(jsc, numList, 1)
  numListRDD2 <- parallelize(jsc, numList, 4)
  strVectorRDD <- parallelize(jsc, strVector, 2)
  strVectorRDD2 <- parallelize(jsc, strVector, 3)
  strListRDD <- parallelize(jsc, strList, 4)
  strListRDD2 <- parallelize(jsc, strList, 1)

  rdds <- c(numVectorRDD,
             numVectorRDD2,
             numListRDD,
             numListRDD2,
             strVectorRDD,
             strVectorRDD2,
             strListRDD,
             strListRDD2)

  for (rdd in rdds) {
    expect_true(inherits(rdd, "RDD"))
    expect_true(.hasSlot(rdd, "jrdd")
                && inherits(rdd@jrdd, "jobj")
                && isInstanceOf(rdd@jrdd, "org.apache.spark.api.java.JavaRDD"))
  }
})

test_that("collect(), following a parallelize(), gives back the original collections", {
  numVectorRDD <- parallelize(jsc, numVector, 10)
  expect_equal(collect(numVectorRDD), as.list(numVector))

  numListRDD <- parallelize(jsc, numList, 1)
  numListRDD2 <- parallelize(jsc, numList, 4)
  expect_equal(collect(numListRDD), as.list(numList))
  expect_equal(collect(numListRDD2), as.list(numList))

  strVectorRDD <- parallelize(jsc, strVector, 2)
  strVectorRDD2 <- parallelize(jsc, strVector, 3)
  expect_equal(collect(strVectorRDD), as.list(strVector))
  expect_equal(collect(strVectorRDD2), as.list(strVector))

  strListRDD <- parallelize(jsc, strList, 4)
  strListRDD2 <- parallelize(jsc, strList, 1)
  expect_equal(collect(strListRDD), as.list(strList))
  expect_equal(collect(strListRDD2), as.list(strList))
})

test_that("regression: collect() following a parallelize() does not drop elements", {
  lapply(1:72,
         function(collLen) {
           lapply(1:15, function(numPart) {
             expected <- runif(collLen)
             actual <- collect(parallelize(jsc, expected, numPart))
             expect_equal(actual, as.list(expected))
           })
         })
})

test_that("parallelize() and collect() work for lists of pairs (pairwise data)", {
  # use the pairwise logical to indicate pairwise data
  numPairsRDDD1 <- parallelize(jsc, numPairs, 1)
  numPairsRDDD2 <- parallelize(jsc, numPairs, 2)
  numPairsRDDD3 <- parallelize(jsc, numPairs, 3)
  expect_equal(collect(numPairsRDDD1), numPairs)
  expect_equal(collect(numPairsRDDD2), numPairs)
  expect_equal(collect(numPairsRDDD3), numPairs)
  # can also leave out the parameter name, if the params are supplied in order
  strPairsRDDD1 <- parallelize(jsc, strPairs, 1)
  strPairsRDDD2 <- parallelize(jsc, strPairs, 2)
  expect_equal(collect(strPairsRDDD1), strPairs)
  expect_equal(collect(strPairsRDDD2), strPairs)
})
