# coding: utf-8
# 此文件只做记录bacon的源代码方法，不做任何引用
def describe(*args, &block)
  context = Bacon::Context.new(args.join(' '), &block)
  (parent_context = self).methods(false).each {|e|
    class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
  }
  @before.each { |b| context.before(&b) }
  @after.each { |b| context.after(&b) }
  context.run
end
def before(&block); @before << block; end
def after(&block);  @after << block; end
def should(*args, &block)
  if Counter[:depth]==0
    it('should '+args.first,&block)
  else
    super(*args,&block)
  end
end
def it(description, &block)
  return  unless description =~ RestrictName
  block ||= lambda { should.flunk "not implemented" }
  Counter[:specifications] += 1
  run_requirement description, block
end
