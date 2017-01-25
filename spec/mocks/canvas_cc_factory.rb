def make_fake_course_with_single_module
  page_ids = ["res001", "res002"]
  page_names = ["This Page", "That Page"]
  module_ids = ["mod1"]
  module_titles = ["Fake Module"]

  courses = [CanvasCc::CanvasCC::Models::Course.new]

  pages = page_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::Page.new.tap do |page|
      page.identifier = id
      page.page_name = page_names[index]
    end
  end

  module_items = page_ids.map do |id|
    CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
      item.content_type = "WikiPage"
      item.identifierref = id
      item.identifier = id
    end
  end

  modules = module_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
      mod.identifier = id
      mod.title = module_titles[index]
    end
  end

  modules[0].module_items.concat(module_items)

  courses[0].canvas_modules << modules[0]
  courses.each { |course| course.pages.concat(pages) }
  courses[0]
end

def make_fake_courses_with_two_modules
  page_ids = ["res001", "res002"]
  page_names = ["This Page", "That Page"]
  module_ids = ["mod1", "mod2", "mod3"]
  module_titles = [
    "Fake Module", "Another Fake Module", "Yet Another Fake Module"
  ]

  courses = [
    CanvasCc::CanvasCC::Models::Course.new,
    CanvasCc::CanvasCC::Models::Course.new,
  ]

  pages = page_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::Page.new.tap do |page|
      page.identifier = id
      page.page_name = page_names[index]
    end
  end

  module_items = page_ids.map do |id|
    CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
      item.content_type = "WikiPage"
      item.identifierref = id
      item.identifier = id
    end
  end

  modules = module_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
      mod.identifier = id
      mod.title = module_titles[index]
    end
  end

  modules[0].module_items.concat(module_items)
  modules[1].module_items << module_items[0]
  modules[2].module_items << module_items[1]

  courses[0].canvas_modules << modules[0]
  courses[1].canvas_modules << modules[1]
  courses[1].canvas_modules << modules[2]
  courses.each { |course| course.pages.concat(pages) }

  courses
end
