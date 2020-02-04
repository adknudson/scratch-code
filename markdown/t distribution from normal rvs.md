# Transforming Normal Random Variables
Theorems are referenced from *An Introduction to Mathematical Statistics and Its Applications*, 5th Ed., Larsen and Marx

## Problem
Suppose that $X_1$, $X_2$, $X_3$, and $X_4$ are independent and identically distributed observations from a standard normal distribution. Determine a constant, $c$, such that the random variable

$$
\frac{ c(X_1 + X_2) }{ \sqrt{X_3^2 + X_4^2} }
$$

has a t-distribution. Specify the degrees of freedom of the t-distribution.

## Solution

**Definition 7.3.3** Let $Z$ be a standard normal random variable and let $U$ be a chi-square random variable independent of $Z$ with $n$ degrees of freedom. The *Student t ratio with n degrees of freedom* is denoted $T_n$, where

$$
T_n = \frac{Z}{ \sqrt{ \frac{U}{n} } }
$$

We will use this ratio as a template to solve this problem.

The sum of two normal random variables is also normal with mean $\mu_1 + \mu_2$ and variance $\sigma_1^2 + \sigma_2^2$. The sum of the squares of two standard normal random variables is a chi-squared distribution with 2 degrees of freedom.

Let $ W = X_1 + X_2 $ and $ U = X_3^2 + X_4^2 $. Then $ W \sim \mathcal{N}(0, 2) $ and $ U \sim \chi_{2}^{2} $.

So now we have the random variable given by

$$
\frac{ c \cdot W }{ \sqrt{U} }
$$

$W$ is not standard normal as **Def 7.3.3** would like, so we will transform it by multiplying $W$ by a constant. The following theorem will help achieve this.

**Theorem 3.6.2** Let $Y$ be a random variable with mean, $\mu$, and where $\text{E} [Y^{2}]$ is finite. Then $\text{Var}(a \cdot Y + b) = a^2 \cdot \text{Var}(Y)$

So now by multiplying $W$ by a constant, we will have

$$
\text{Var}(a \cdot W) = a^2 \text{Var}(W) = a^2 \cdot 2
$$

A normal distribution has a variance of $1$, so $2a^2=1 \rightarrow a=\frac{1}{\sqrt{2}}$

If we multiply $W$ by $\frac{1}{\sqrt{2}}$, then we'll have a standard normal distribution.

$$
\frac{ \sqrt{2} \cdot W \cdot \frac{1}{ \sqrt{2} } }{ \sqrt{U} } \rightarrow
\frac{ \sqrt{2} \cdot Z }{ \sqrt{U} }
$$

Notice at this point, we haven't applied the variable $c$ to the random variable. The idea is to transform the random variable that we have so that it looks like $T_n$ multiplied by some constant. Afterwards, $c$ must be the inverse of whatever constant is remaining.

Let's now shift our focus to $U$.

With some simple algebra, we see that

$$
U = 2 \cdot U \cdot \frac{1}{2}
$$

and therefore we can simplify the random variable.

$$
\frac{ \sqrt{2} \cdot Z }{ \sqrt{U} } \rightarrow
\frac{ \sqrt{2} \cdot Z }{ \sqrt{2 \cdot \frac{U}{2}} } \rightarrow
\frac{ \sqrt{2} \cdot Z }{ \sqrt{2}\sqrt{\frac{U}{2}} } \rightarrow
\frac{ Z }{ \sqrt{\frac{U}{2}} }
$$

By **Definition 7.3.3**,

$$
\frac{ Z }{ \sqrt{\frac{U}{2}} } = T_2
$$

We don't even have to multiply the result by anything, implying that $c=1$ is the solution, and our random variable has a t distribution with 2 degrees of freedom.

## Conclusion
As a concluding side note, if there are $2k$ independent and identically distributed observations from a standard normal distribution, then the random variable

$$
\frac{ X_1 + ... + X_k }{ \sqrt{X_{k+1}^2 + ... + X_{2k}^2} }
$$

has a t distribution with $k$ degrees of freedom. The proof is left to the reader ;)
