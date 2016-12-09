module Blacklight
  class Module
    def canvas_conversion(cc_module)
      module_item = CanvasCc::CanvasCC::Models::ModuleItem.new
      cc_module.items << module_item
      cc_module
    end
  end
end
