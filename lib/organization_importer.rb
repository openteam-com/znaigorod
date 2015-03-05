class OrganizationImporter
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def categories
    @categories ||= begin
                      hash = data.map { |r| r[3] }.uniq.delete_if(&:blank?).sort!.inject({}) { |h, c| h[c] ||= {}; h }

                      data.inject(hash) do |h, r|
                        if r[3].present?
                          h[r[3]][r[4]] ||= []
                          h[r[3]][r[4]] << r[5]
                          h[r[3]][r[4]].uniq!
                        end

                        h
                      end
                    end
  end

  private

  def data
    @data ||= CSV.read(path, :col_sep => ';')[1..-1]
  end

  def organizations
  end
end
