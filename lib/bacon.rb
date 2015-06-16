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

def run
  return  unless name =~ RestrictContext
  Counter[:context_depth] += 1
  Bacon.handle_specification(name) { instance_eval(&block) }
  Counter[:context_depth] -= 1
  self
end

def run_requirement(description, spec)
  Bacon.handle_requirement description do
    begin
      Counter[:depth] += 1
      rescued = false
      begin
        @before.each { |block| instance_eval(&block) }
        prev_req = Counter[:requirements]
        instance_eval(&spec)
      rescue Object => e
        rescued = true
        raise e
      ensure
        if Counter[:requirements] == prev_req and not rescued
          raise Error.new(:missing,
                          "empty specification: #{@name} #{description}")
        end
        begin
          @after.each { |block| instance_eval(&block) }
        rescue Object => e
          raise e  unless rescued
        end
      end
    rescue Object => e
      ErrorLog << "#{e.class}: #{e.message}\n"
      e.backtrace.find_all { |line| line !~ /bin\/bacon|\/bacon\.rb:\d+/ }.
        each_with_index { |line, i|
        ErrorLog << "~~~~ "
      }

      ErrorLog << "\n"

      if e.kind_of? Error
        Counter[e.count_as] += 1
        e.count_as.to_s.upcase
      else
        Counter[:errors] += 1
        "ERROR: #{e.class}"
      end
    else
      ""
    ensure
      Counter[:depth] -= 1
    end
  end
end
