<div align="center">
    <h1>Alignment of Bodies in Orbital Motion</h1>
    <h2>An Approach to Synodic Periods through Modular Arithmetic</h2>
</div>

**The Problem**: Two objects are in a concentric circular orbit, with object $A$ making one revolution in $f$ units of time and object $B$ making one revolution in $g$ units of time. If the two objects are in alignment at time $t_0=0$, how long until they are in alignment again?

### Background

This question was given to me by a coworker, as we would often throw around interesting math questions at each other. I don't remember the exact numbers, but the original question was along the lines of
> Two planets are orbiting around a star. One planet makes a full revolution in 1140 days and the other planet makes one revolution in 780 days. If they started out in alignment with the star, how long until they are in alignment again?

My initial thought was that you simply take the lowest common multiple of the two planets' revolution periods and you'll have your answer.

$$ LCM(780, 1140)=14820 $$

That was easy! They'll be in alignment again after 14,820 days. Well, not actually. I was reminded that the planets could be in alignment at some other radial position, and that my answer is just when they would be back in their original positions.

Well shoot, now how do I approach this problem? Coincidentally, I was taking a course on number theory that semester, and had picked up this new tool called *modular arithmetic*.



### Modular Arithmetic

The easiest way to explain modular arithmetic is to think of a clock in a 24 hour format. What time is represented by `15:00`? Most  people would figure this out by subtracting 12 from 15 and figure out that `15:00` is the same as `3:00` pm. Similarly, a time such as `05:00` is already less than 12, so there's no need to do any subtracting.

So here's where the math comes in. In math (and especially in computer science), the modulo operator, $\%$, yields the remainder of a division problem:

$$ 15\ \%\ 12\ =\ 3 $$

In english, 12 goes into 15 one time with a remainder of **3**. The modulo operator returns the remainder! In formal notation, we can say 15:00 is *congruent* to 3:00 (on a 12 hour scale).
$$ 15 \equiv 3\ (\text{mod}\ 12) $$

Okay, so now how can we use that? Well let's think about that clock again, particularly the hour and minute hands of a clock. At noon, they are both pointing straight up, but then as time goes on, the minute hand moves ahead faster than the hour hand, and they meet back up somewhere a little after 1:05. Sounds just like the planet question, doesn't it? With one more definition, we can solve this problem.

**Definition**: We say $ a\equiv b \pmod{c} $  if  $ \frac{a-b}{c}, c\ne 0 $ is an integer.

**Lemma**: If $ \frac{a-b}{c}, c\ne 0 $ is an integer, then so is $ \frac{a-b}{-c} = \frac{-(a-b)}{c} $, hence $ a\equiv b\ (\text{mod}\ c) $ if and only if $ a\equiv b \bmod -c $

In other words, if the two planets are in alignment, then the difference in their angular position will be divisible by the number of units in a circle. Furthermore, even if we switch the difference order, the integer value should remain the same.

### Setting up the Problem

#### Variables
$
\quad \quad \theta : \text{angular units in a circle (e.g. 2} \pi \text{ radians)}
\\ \quad \quad \omega : \text{angular velocity (e.g. radians per day)}
\\ \quad \quad \alpha : \text{angle from starting position}
\\ \quad \quad t\ : \text{units of time}
$
#### Equations
$
\quad \quad \omega_{A}=\frac{\theta}{f}
\\ \quad \quad \omega_{A}=\frac{\theta}{g}
\\ \quad \quad \alpha_{A}\equiv \omega_{A}\cdot t\ (\text{mod}\ \theta)
\\ \quad \quad \alpha_{B}\equiv \omega_{B}\cdot t\ (\text{mod}\ \theta)
$

**Explanation**: Just like with the clock problem, we can model the planets angular position and determine when the two positions are equal. The modular part comes into play when one planet makes a full revolution before the other and starts back around (i.e. when the minute hand reaches 12 o'clock and it starts back at 0).

Now we can pose the problem as when does $ \alpha_{A} = \alpha_{B} $ ?

### Solving the Problem

To begin, $ \alpha_{A} = \alpha_{B} $ whenever $ \omega_{A} \cdot t \equiv \omega_{B} \cdot t\ (\text{mod } \theta) $

Necessarily, $ \omega_{A} \cdot t \equiv \omega_{B} \cdot t\ (\text{mod } \theta) $ if
$$ \frac{\omega_{A} \cdot t - \omega_{B} \cdot t}{\theta} = k, k\in \Bbb{Z} $$

Let us assume that the above condition is true, since the two planets must align at some point. We can rearrange the equation to give

$$ \theta \cdot k = \omega_{A} \cdot t - \omega_{B} \cdot t $$

Since we are trying to find the time at which the two planets are aligned, we can solve for $t$.

$$ t = \frac{\theta \cdot k}{\omega_{A} - \omega_{B}} $$

For the problem, we can only assume that the time is a positive value. Hence the $\text{sgn(}\omega_{A} - \omega_{B}) = \text{sgn(}k)$ , and we can simplifly the equation by taking the absolute value of $\omega_{A} - \omega_{B}$ and restricting $k$ to nonnegative integers.

$$ t = \frac{\theta \cdot k}{ \left |\omega_{A} - \omega_{B}\right |}, k\in \Bbb{N}^0 $$

And that's it! we have now solved for the time as a function of $k$ and parameterized by $\theta$, $\omega_{A}$, and $\omega_{B}$. In the context of the problem, $k$ represents the $k^{\text{th}}$ time that the two planets will be in alignment. Let's try it out!

### Testing the Solution

#### Original Problem
$
\quad \quad \omega_{A}=\frac{2\pi}{1140}\ \text{radians per day}
\\ \quad \quad \omega_{B}=\frac{2\pi}{780}\ \text{radians per day}
$

We want to figure out when the first time the two planets align is, so we let $k=1$. Therefore
$$ t=\frac{2\pi \cdot 1}{\left |\frac{2\pi}{1140} - \frac{2\pi}{780}\right |} = \text{2470 days}$$

I've provided a little simple desmos graph animation to illustrate what's going on. As you can see, the two planets have a conjunction every 2470 days. Just as we computed!

<iframe src="https://www.desmos.com/calculator/7jyhsmjey9?embed" width="500px" height="500px" style="border: 1px solid #ccc" frameborder=0></iframe>

### Conclusion
I haven't yet addressed what a synodic period is. When I first approached this problem, I had never heard of it either, and hadn't realized that this was a common problem! From Wikipedia:
> The synodic period is the amount of time that it takes for an object to reappear at the same point in relation to two or more other objects (e.g. the Moon's phase and its position relative to the Sun and Earth repeats every 29.5 day synodic period, longer than its 27.3 day orbit around the Earth, due to the motion of the Earth about the Sun). The time between two successive oppositions or conjunctions is also an example of the synodic period. For the planets in the solar system, the synodic period (with respect to Earth) differs from the sidereal period due to the Earth's orbiting around the Sun.

Furthermore, the synodic period, $P_{syn}$, of two planets is given by
$$ \frac{1}{P_{syn}}=\frac{1}{P_1} - \frac{1}{P_2}$$
or rather
$$ P_{syn} = \frac{1}{\frac{1}{P_1} - \frac{1}{P_2}} $$

This is all very good news, because my solution can be directly transformed into the above equation

$$ t = \frac{\theta}{ \left |\omega_{A} - \omega_{B}\right |} = \frac{\theta}{ \left |\frac{\theta}{f} - \frac{\theta}{g}\right |} = \frac{\theta}{\theta \left |(\frac{1}{f} - \frac{1}{g})\right |} = \frac{1}{\left |\frac{1}{f} - \frac{1}{g}\right |}$$

Copernicus was the first $^{\text{[citation needed]}}$ to derive this equation, and as you can see [here](http://astro.unl.edu/naap/ssm/ssm_advanced.html), it can be derived with geometry alone. The popular youtube channel, [numberphile](https://www.youtube.com/user/numberphile/), worked out the [similar problem with clocks](https://www.youtube.com/watch?v=HcqdqsQq-6M).

I favor my method, however, because it requires no intuition to derive the equation, and also works if the planets are in counter-orbit (rotational velocity of one of the planets is negative). So if we stick to the planets from above, with one of them going in the opposite direction, we get
$$ t=\frac{2\pi \cdot 1}{\left |\frac{2\pi}{-1140} - \frac{2\pi}{780}\right |} = 463 \frac{1}{8} \text{ days}$$


<iframe src="https://www.desmos.com/calculator/arjvtqmpsh?embed" width="500px" height="500px" style="border: 1px solid #ccc" frameborder=0></iframe>

Thanks for reading, and if there you have any suggestions for improving this article for accuracy or clarity, please let me know in the comment section below!
