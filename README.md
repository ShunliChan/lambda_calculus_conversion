聊聊用lambda表达式的化简来化简你的Gem包 (以rack的测试框架bacon为例)
========
我们常常会因为复杂的代码块链的调用而犯晕, 尤其是在加上系统的OO就更复杂
了，所以：简化Gem包的代码流或数据流的方式是，先去除OO用块的名字代替，
然后用lambda来表示整个Gem包的代码流或数据流，最后再加上OO 
```ruby
describe.("rack_head") do
  ... 
end
```
