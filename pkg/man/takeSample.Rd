\docType{methods}
\name{takeSample}
\alias{takeSample}
\alias{takeSample,RDD}
\alias{takeSample,RDD,logical,integer,integer-method}
\title{Return a list of the elements that are a sampled subset of the given RDD.}
\usage{
takeSample(rdd, withReplacement, num, seed)

\S4method{takeSample}{RDD,logical,integer,integer}(rdd, withReplacement, num,
  seed)
}
\arguments{
  \item{rdd}{The RDD to sample elements from}

  \item{withReplacement}{Sampling with replacement or not}

  \item{num}{Number of elements to return}

  \item{seed}{Randomness seed value}
}
\description{
Return a list of the elements that are a sampled subset of
the given RDD.
}
\examples{
\dontrun{
sc <- sparkR.init()
rdd <- parallelize(sc, 1:100)
# exactly 5 elements sampled, which may not be distinct
takeSample(rdd, TRUE, 5L, 1618L)
# exactly 5 distinct elements sampled
takeSample(rdd, FALSE, 5L, 16181618L)
}
}

