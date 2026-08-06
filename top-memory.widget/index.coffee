command: "top -l 1 -o mem -n 5 -stats command,mem,pid | tail -n 5 | awk '{ pid=$NF; mem=$(NF-1); cmd=\"\"; for(i=1;i<=NF-2;i++) cmd=cmd (i>1?\" \":\"\") $i; if (mem ~ /M$/) { val = substr(mem, 1, length(mem)-1) + 0; if (val >= 1024) mem = sprintf(\"%.2fG\", val/1024) } sub(/M$/, \"MB\", mem); sub(/G$/, \"GB\", mem); sub(/K$/, \"KB\", mem); print mem\",\"cmd\",\"pid }'"

# Enable or disable this widget.
widgetEnabled: true   # true | false

refreshFrequency: '5s'

style: """
  // Change bar height
  bar-height = 6px

  // Align contents left or right
  widget-align = left

  // grid: col 1 · row 6 · 1×1  (see LAYOUT.md)
  top 502px
  left 10px

  // Statistics text settings
  color var(--text, #fff)
  text-shadow: 0 1px 1px rgba(20, 1, 1, 0.2)
  font-family -apple-system, BlinkMacSystemFont, system-ui, sans-serif
  background var(--panel-bg, rgba(#000, .15))
  -webkit-backdrop-filter: blur(var(--panel-blur, 48px))
  backdrop-filter: blur(var(--panel-blur, 48px))
  padding 9px 10px 10px 10px
  border-radius 10px

  .container
    width: calc(var(--grid-col, 320px) - 20px)
    text-align: widget-align
    position: relative
    clear: both

  .widget-title
    text-align: widget-align
    font-size 10px
    text-transform uppercase
    font-weight bold
    margin-bottom: 1px

  .stats-container
    margin-bottom 0
    border-collapse collapse

  td
    font-size: 11px
    font-weight: 300
    line-height: 1.4   // room for descenders (g/y/p); .label uses overflow:hidden, which clips them at line-height 1
    text-align: widget-align
    position: relative

  .label
    float: left
    width: 220px
    overflow: hidden
    white-space: nowrap
    text-overflow: ellipsis
    text-transform: capitalize

  .percentage
    float: right
    font-weight: bold

  sup
    position: relative
    font-size: 8px
    top: 1px
"""

render: -> """
  <div class="container">
    <div class="widget-title">Top Memory</div>
    <table class="stats-container" width="100%">
      <tr>
        <td class='col1'></td>
      </tr>
      <tr>
        <td class='col2'></td>
      </tr>
      <tr>
        <td class='col3'></td>
      </tr>
      <tr>
        <td class='col4'></td>
      </tr>
      <tr>
        <td class='col5'></td>
      </tr>
    </table>
  </div>
"""

update: (output, domEl) ->
  # Hide entirely when disabled.
  if not @widgetEnabled
    $(domEl).css('display', 'none')
    return
  $(domEl).css('display', '')
  processes = output.split('\n')
  table     = $(domEl).find('table')

  renderProcess = (mem, name, id) ->
    "<div class='wrapper'>" +
      "<div class='label'>#{name} <sup>(#{id})</sup></div><div class='percentage'>#{mem}</div>" +
    "</div>"

  for process, i in processes
    args = process.split(',')
    if args[1] != 'top'
      table.find(".col#{i+1}").html renderProcess(args...)
