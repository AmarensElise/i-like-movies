module ApplicationHelper
  # Wraps an image in a container with VHS texture overlays.
  #
  # Usage:
  #   <%= vhs_image(src: "https://image.tmdb.org/t/p/w500#{movie.poster_path}",
  #                 alt: movie.title,
  #                 image_class: "w-full h-auto object-cover shadow-lg rounded-xl",
  #                 container_class: "md:w-1/3 lg:w-1/4") %>
  #
  # Or with a block for custom content:
  #   <%= vhs_image(container_class: "w-48") do %>
  #     <img src="..." class="..." />
  #   <% end %>
  #
  def vhs_image(src: nil, alt: "", image_class: "w-full h-auto object-cover shadow-lg rounded-xl", container_class: "", rounded: "rounded-xl", &block)
    content_tag(:div, class: "relative #{container_class}") do
      if block_given?
        capture(&block) +
        render(partial: "shared/vhs_overlay", locals: { rounded: rounded })
      else
        image_tag(src, alt: alt, class: image_class) +
        render(partial: "shared/vhs_overlay", locals: { rounded: rounded })
      end
    end
  end
end
