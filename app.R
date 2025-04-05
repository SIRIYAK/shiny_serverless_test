# GitHub Actions Deployment Simulation App

library(shiny)
library(bslib)
library(shinyjs)
library(shinyWidgets)  # Added for progressBar

ui <- page_sidebar(
  title = "GitHub Actions Deployment Simulator",
  theme = bs_theme(bootswatch = "flatly"),
  
  useShinyjs(),
  
  sidebar = sidebar(
    title = "Setup Steps",
    
    div(
      id = "step1",
      actionButton("setup_repo", "1. Setup GitHub Repository", class = "btn-block btn-info mb-2"),
      hidden(div(id = "step1_done", tags$small("✓ Repository created!", class = "text-success")))
    ),
    
    div(
      id = "step2",
      actionButton("setup_shinyapps", "2. Get shinyapps.io Credentials", class = "btn-block btn-info mb-2"),
      hidden(div(id = "step2_done", tags$small("✓ Credentials obtained!", class = "text-success")))
    ),
    
    div(
      id = "step3",
      actionButton("setup_secrets", "3. Setup GitHub Secrets", class = "btn-block btn-info mb-2"),
      hidden(div(id = "step3_done", tags$small("✓ Secrets added!", class = "text-success")))
    ),
    
    div(
      id = "step4",
      actionButton("setup_workflow", "4. Create Workflow File", class = "btn-block btn-info mb-2"),
      hidden(div(id = "step4_done", tags$small("✓ Workflow created!", class = "text-success")))
    ),
    
    div(
      id = "step5",
      actionButton("deploy", "5. Push & Deploy", class = "btn-block btn-success mb-2"),
      hidden(div(id = "step5_done", tags$small("✓ Deployment successful!", class = "text-success")))
    ),
    
    hr(),
    actionButton("reset", "Reset Simulation", class = "btn-block btn-outline-danger")
  ),
  
  card(
    card_header("Simulation Display"),
    div(id = "content_main",
        p("Welcome to the GitHub Actions Deployment Simulator. Follow the steps in the sidebar to learn how to set up automated deployment of your Shiny app to shinyapps.io."),
        p("Click the first button to begin!")
    )
  ),
  
  card(
    card_header("Terminal Output"),
    div(
      id = "terminal",
      class = "bg-dark text-light p-3",
      style = "font-family: monospace; height: 200px; overflow-y: auto;",
      "$ _"
    )
  ),
  
  card(
    card_header("Deployment Status"),
    div(
      id = "status_panel",
      progressBar("deploy_progress", value = 0, display_pct = TRUE, 
                  status = "info", striped = TRUE),
      p(id = "status_message", "Not started")
    )
  )
)

server <- function(input, output, session) {
  # Keep track of completed steps
  steps_completed <- reactiveVal(0)
  
  # Add content to terminal
  add_terminal_text <- function(text) {
    current <- HTML(paste0(isolate(input$terminal), "<br>$ ", text))
    updateTextInput(session, "terminal", value = current)
  }
  
  # Update progress
  update_progress <- function(value, message) {
    updateProgressBar(session, "deploy_progress", value = value)
    html(id = "status_message", message)
  }
  
  # Step 1: Setup GitHub Repository
  observeEvent(input$setup_repo, {
    # Update content area with repository setup info
    html("content_main", 
         HTML("<h4>Step 1: Setup GitHub Repository</h4>
              <ol>
                <li>Create a new GitHub repository or use an existing one</li>
                <li>Clone the repository to your local machine</li>
                <li>Add your Shiny app files to the repository</li>
                <li>Commit and push your app files to GitHub</li>
              </ol>
              <p><strong>Code structure required:</strong></p>
              <pre>your-repo/
  app.R          # Your main Shiny app file
  .github/       # Will be created in Step 4
    workflows/   # Will be created in Step 4
  [Other app files as needed]</pre>"))
    
    # Add terminal text
    add_terminal_text("git init")
    Sys.sleep(0.5)
    add_terminal_text("git add .")
    Sys.sleep(0.5)
    add_terminal_text("git commit -m 'Initial commit of Shiny app'")
    Sys.sleep(0.5)
    add_terminal_text("git remote add origin https://github.com/username/repo.git")
    Sys.sleep(0.5)
    add_terminal_text("git push -u origin main")
    Sys.sleep(0.5)
    add_terminal_text("Repository setup complete!")
    
    # Update progress
    update_progress(20, "GitHub repository created and Shiny app files added")
    
    # Mark step as complete
    hide("step1")
    show("step1_done")
    steps_completed(1)
  })
  
  # Step 2: Get shinyapps.io Credentials
  observeEvent(input$setup_shinyapps, {
    req(steps_completed() >= 1)
    
    # Update content area
    html("content_main", 
         HTML("<h4>Step 2: Get shinyapps.io Credentials</h4>
              <ol>
                <li>Log in to your <a href='https://www.shinyapps.io/' target='_blank'>shinyapps.io</a> account</li>
                <li>Navigate to Account → Tokens</li>
                <li>Click 'Show' or 'Add Token' to view/create your tokens</li>
                <li>Copy your account name, token, and secret</li>
              </ol>
              <p><strong>The credentials you'll need:</strong></p>
              <pre>Account Name: your-account-name
Token: A long string like 'ABC123DEF456GHI789...'
Secret: Another long string like 'JKL012MNO345PQR678...'</pre>
              <p>These will be used in the next step to set up GitHub Secrets.</p>"))
    
    # Add terminal text
    add_terminal_text("Navigating to shinyapps.io...")
    Sys.sleep(0.5)
    add_terminal_text("Accessing Account → Tokens page")
    Sys.sleep(0.5)
    add_terminal_text("Credentials acquired! (Keep these secure)")
    
    # Update progress
    update_progress(40, "shinyapps.io credentials obtained")
    
    # Mark step as complete
    hide("step2")
    show("step2_done")
    steps_completed(2)
  })
  
  # Step 3: Setup GitHub Secrets
  observeEvent(input$setup_secrets, {
    req(steps_completed() >= 2)
    
    # Update content area
    html("content_main", 
         HTML("<h4>Step 3: Setup GitHub Secrets</h4>
              <ol>
                <li>Go to your GitHub repository</li>
                <li>Click on 'Settings' → 'Secrets and variables' → 'Actions'</li>
                <li>Click on 'New repository secret'</li>
                <li>Add the following secrets one by one:
                  <ul>
                    <li><code>SHINYAPPS_ACCOUNT</code>: Your shinyapps.io account name</li>
                    <li><code>SHINYAPPS_TOKEN</code>: Your shinyapps.io token</li>
                    <li><code>SHINYAPPS_SECRET</code>: Your shinyapps.io secret</li>
                    <li><code>SHINYAPP_NAME</code>: The name you want to give your app on shinyapps.io</li>
                  </ul>
                </li>
              </ol>
              <p>These secrets will be securely used by the GitHub Actions workflow to authenticate with shinyapps.io.</p>"))
    
    # Add terminal text
    add_terminal_text("Adding GitHub secret: SHINYAPPS_ACCOUNT")
    Sys.sleep(0.5)
    add_terminal_text("Adding GitHub secret: SHINYAPPS_TOKEN")
    Sys.sleep(0.5)
    add_terminal_text("Adding GitHub secret: SHINYAPPS_SECRET")
    Sys.sleep(0.5)
    add_terminal_text("Adding GitHub secret: SHINYAPP_NAME")
    Sys.sleep(0.5)
    add_terminal_text("All secrets added successfully")
    
    # Update progress
    update_progress(60, "GitHub secrets configured")
    
    # Mark step as complete
    hide("step3")
    show("step3_done")
    steps_completed(3)
  })
  
  # Step 4: Create Workflow File
  observeEvent(input$setup_workflow, {
    req(steps_completed() >= 3)
    
    # Update content area
    html("content_main", 
         HTML("<h4>Step 4: Create Workflow File</h4>
              <ol>
                <li>Create directories <code>.github/workflows/</code> in your repository</li>
                <li>Create a file named <code>deploy.yml</code> inside the workflows directory</li>
                <li>Add the following content to the file:</li>
              </ol>
              <pre>name: Deploy to shinyapps.io

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.2.0'
          
      - name: Install dependencies
        run: |
          install.packages(c(\"shiny\", \"rsconnect\", \"bslib\"))
        shell: Rscript {0}
          
      - name: Set up rsconnect
        run: |
          rsconnect::setAccountInfo(
            name=\"${{ secrets.SHINYAPPS_ACCOUNT }}\",
            token=\"${{ secrets.SHINYAPPS_TOKEN }}\",
            secret=\"${{ secrets.SHINYAPPS_SECRET }}\"
          )
        shell: Rscript {0}
        
      - name: Deploy app
        run: |
          rsconnect::deployApp(
            appDir = \".\",
            appName = \"${{ secrets.SHINYAPP_NAME }}\",
            account = \"${{ secrets.SHINYAPPS_ACCOUNT }}\"
          )
        shell: Rscript {0}</pre>
              <p>This workflow file tells GitHub Actions to deploy your app when changes are pushed to the main/master branch.</p>"))
    
    # Add terminal text
    add_terminal_text("mkdir -p .github/workflows")
    Sys.sleep(0.5)
    add_terminal_text("mkdir -p .github/workflows")
    Sys.sleep(0.5)
    add_terminal_text("Creating file: .github/workflows/deploy.yml")
    Sys.sleep(0.5)
    add_terminal_text("Workflow file created with GitHub Actions configuration")
    
    # Update progress
    update_progress(80, "GitHub Actions workflow file created")
    
    # Mark step as complete
    hide("step4")
    show("step4_done")
    steps_completed(4)
  })
  
  # Step 5: Push & Deploy
  observeEvent(input$deploy, {
    req(steps_completed() >= 4)
    
    # Update content area
    html("content_main", 
         HTML("<h4>Step 5: Push & Deploy</h4>
              <ol>
                <li>Commit your workflow file to the repository</li>
                <li>Push the changes to GitHub</li>
                <li>GitHub Actions will automatically detect the push and run the workflow</li>
                <li>Monitor the progress in the 'Actions' tab of your repository</li>
                <li>Once completed, your app will be live on shinyapps.io!</li>
              </ol>
              <div class='alert alert-success'>
                <strong>Success!</strong> Your app is now set up for continuous deployment!
                <p>Every time you push changes to your repository, GitHub Actions will automatically deploy the updated app to shinyapps.io.</p>
                <p>Your app is available at: <code>https://[YOUR-ACCOUNT].shinyapps.io/[APP-NAME]/</code></p>
              </div>"))
    
    # Simulate deployment with terminal output
    add_terminal_text("git add .github/workflows/deploy.yml")
    Sys.sleep(0.5)
    add_terminal_text("git commit -m 'Add GitHub Actions workflow for deployment'")
    Sys.sleep(0.5)
    add_terminal_text("git push origin main")
    Sys.sleep(0.5)
    add_terminal_text("Triggering GitHub Actions workflow...")
    Sys.sleep(1)
    add_terminal_text("GitHub Actions: Setting up R environment...")
    Sys.sleep(1)
    add_terminal_text("GitHub Actions: Installing dependencies...")
    Sys.sleep(1)
    add_terminal_text("GitHub Actions: Setting up rsconnect...")
    Sys.sleep(1)
    add_terminal_text("GitHub Actions: Deploying to shinyapps.io...")
    Sys.sleep(1.5)
    add_terminal_text("Deployment successful! App is now live at https://[account].shinyapps.io/[app-name]/")
    
    # Update progress
    update_progress(100, "Deployment completed! App is live on shinyapps.io")
    
    # Mark step as complete
    hide("step5")
    show("step5_done")
    steps_completed(5)
  })
  
  # Reset simulation
  observeEvent(input$reset, {
    # Reset content
    html("content_main", HTML("<p>Welcome to the GitHub Actions Deployment Simulator. Follow the steps in the sidebar to learn how to set up automated deployment of your Shiny app to shinyapps.io.</p><p>Click the first button to begin!</p>"))
    
    # Reset terminal
    html("terminal", "$ _")
    
    # Reset progress
    update_progress(0, "Not started")
    
    # Reset step display
    for (i in 1:5) {
      show(paste0("step", i))
      hide(paste0("step", i, "_done"))
    }
    
    # Reset steps counter
    steps_completed(0)
  })
  
  # Disable buttons until previous steps completed
  observe({
    toggleState("setup_shinyapps", condition = steps_completed() >= 1)
    toggleState("setup_secrets", condition = steps_completed() >= 2)
    toggleState("setup_workflow", condition = steps_completed() >= 3)
    toggleState("deploy", condition = steps_completed() >= 4)
  })
}

shinyApp(ui, server)